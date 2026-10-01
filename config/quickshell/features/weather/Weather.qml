pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Weather feature facade. Owns the two network sources, the stored location and
// the refresh clock; the bar button reads `label` and the panel reads the rest
// through this object.
Scope {
    id: root

    required property var screen

    property bool open: false

    readonly property string locationTool: Quickshell.shellPath("features/weather/scripts/qs-weather-location")
    readonly property string locationFilePath: (Quickshell.env("XDG_STATE_HOME")
        || Quickshell.env("HOME") + "/.local/state") + "/quickshell/weather.json"

    function toggle() {
        open = !open
    }

    function close() {
        open = false
        cancelEditingLocation()
    }

    // True while a fetch is in flight, so the refresh button can spin.
    readonly property bool busy: forecastProc.running || dailyForecastProc.running

    function refresh() {
        // Each full cycle gets a fresh retry budget, so an exhausted round (a
        // laptop waking with no network yet) does not starve the retries for
        // the rest of the session.
        forecastRetries = 0
        dailyForecastRetries = 0
        if (!forecastProc.running)
            forecastProc.running = true
        if (root.locationQuery === "" && !locationProc.running)
            locationProc.running = true
        // With stored coordinates this fetches Open-Meteo immediately, without
        // waiting on the slow wttr response. Without them it waits for wttr to
        // report the detected area.
        root.refreshDailyForecast(null)
    }

    // ---------- Location ----------

    // Parsed weather.json. The query is the wttr.in path segment: coordinates
    // when stored, else the encoded name; empty means IP auto-detect. The file
    // is watched so hand edits take effect live.
    property var configuredLocationState: ({ name: "", latitude: null, longitude: null })
    readonly property string configuredLocation: configuredLocationState.name
    readonly property bool hasConfiguredCoordinates: !isNaN(parseFloat(String(configuredLocationState.latitude)))
        && !isNaN(parseFloat(String(configuredLocationState.longitude)))
    readonly property string locationQuery: WeatherLabels.wttrLocationQuery(
        configuredLocationState.name,
        configuredLocationState.latitude,
        configuredLocationState.longitude)

    FileView {
        id: locationFile

        path: root.locationFilePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.configuredLocationState = WeatherLabels.parseLocationFile(text)
        onLoadFailed: root.configuredLocationState = WeatherLabels.parseLocationFile("")
    }

    // The first read can race shell startup, leaving a stored location unhonored
    // until the next write. One delayed reload self-corrects; if the first read
    // was fine it is a no-op, because identical state does not change
    // locationQuery and so triggers no refetch.
    Timer {
        interval: 1500
        running: true
        onTriggered: locationFile.reload()
    }

    onLocationQueryChanged: {
        if (savingLocation)
            savingLocationQueryStarted = true
        forecastRetries = 0
        dailyForecastRetries = 0
        forecastProc.running = false
        dailyForecastProc.running = false
        Qt.callLater(root.refresh)
    }

    // Click the location label to swap it for a search field. An empty commit
    // goes back to IP auto-detect.
    property bool editingLocation: false
    property bool savingLocation: false
    property bool savingLocationQueryStarted: false
    property var locationSuggestions: []
    property int suggestionIndex: 0
    property string geocodePendingQuery: ""
    property string geocodeActiveQuery: ""

    // The panel owns the text field; it reacts to editingLocation to focus and
    // seed it, and hands the text back here to commit.
    function startEditingLocation() {
        editingLocation = true
        savingLocation = false
        savingLocationQueryStarted = false
        locationSuggestions = []
        suggestionIndex = 0
    }

    function cancelEditingLocation() {
        editingLocation = false
        savingLocation = false
        savingLocationQueryStarted = false
        locationSuggestions = []
        geocodeDebounce.stop()
    }

    // The panel calls this per keystroke; the newest query is the one that runs.
    function geocodeChanged(text) {
        if (!editingLocation || savingLocation)
            return
        geocodeDebounce.query = String(text || "").trim()
        geocodeDebounce.restart()
    }

    function commitLocation(text) {
        const location = WeatherLabels.locationCommit(
            text,
            locationSuggestions,
            suggestionIndex)
        if (location.name === "") {
            root.clearLocation()
            return
        }
        savingLocation = true
        savingLocationQueryStarted = false
        configuredLocationState = {
            name: location.name,
            latitude: location.latitude,
            longitude: location.longitude
        }
        root.persistLocation(location.name, location.latitude, location.longitude)
    }

    function clearLocation() {
        root.persistLocation("", null, null)
        wttrLocation = ""
        root.cancelEditingLocation()
    }

    function pickSuggestion(suggestion) {
        if (!suggestion)
            return
        savingLocation = true
        savingLocationQueryStarted = false
        configuredLocationState = {
            name: suggestion.name,
            latitude: suggestion.latitude,
            longitude: suggestion.longitude
        }
        root.persistLocation(suggestion.name, suggestion.latitude, suggestion.longitude)
    }

    function persistLocation(name, latitude, longitude) {
        if (name && latitude !== null && longitude !== null)
            locationSaveProc.command = [root.locationTool, "--set", name, latitude + "," + longitude]
        else if (name)
            locationSaveProc.command = [root.locationTool, "--set", name]
        else
            locationSaveProc.command = [root.locationTool, "--clear"]
        locationSaveProc.running = true
    }

    // Debounced geocoding. Only one request runs at a time; if the query moved
    // on while one was in flight, the newest query is fetched right after.
    function requestGeocode(text) {
        const query = String(text || "").trim()
        if (query.length < 2) {
            locationSuggestions = []
            return
        }
        geocodePendingQuery = query
        if (!geocodeProc.running)
            root.startGeocode()
    }

    function startGeocode() {
        geocodeActiveQuery = geocodePendingQuery
        geocodeProc.command = ["curl", "-fsS", "--max-time", "5",
            "https://geocoding-api.open-meteo.com/v1/search?name="
            + encodeURIComponent(geocodeActiveQuery)
            + "&count=5&language=en&format=json"]
        geocodeProc.running = true
    }

    // ---------- Reports ----------

    // Parsed wttr.in j1 response. Kept on failure so stale data stays visible.
    property var report: null
    property var dailyForecastReport: null
    // wttr's resolved place when no coordinates are stored (IP auto-detect).
    property string wttrLocation: ""
    // Coordinates for the detected place, never stored. The name is geocoded
    // first: ipwho.is answers with the ISP's rough location, which was Karachi
    // while the label said Faisalabad, so the panel showed one city's name over
    // another city's forecast.
    property real detectedLatitude: NaN
    property real detectedLongitude: NaN

    property int forecastRetries: 0
    property int dailyForecastRetries: 0
    readonly property int maxRetries: 2

    // Bar glyph. Fixed rather than a condition read-out: the button is an
    // ambient weather indicator, and flipping between sun / cloud / rain there
    // made it look like a different notification each time. The condition lives
    // in the panel, one click away.
    readonly property string label: WeatherLabels.iconForCode(119)

    readonly property var openMeteoCurrent: WeatherLabels.openMeteoCurrentCondition(dailyForecastReport)
    // One source for the numbers, always. Reading the hero from wttr.in while
    // the forecast came from Open-Meteo put two different places on screen at
    // once (a 38 °C hero above a 30° day). Open-Meteo answers for whatever
    // location the forecast was fetched for, so it wins whenever it is there.
    readonly property var current: openMeteoCurrent
        ? openMeteoCurrent
        : ((report && report.current_condition && report.current_condition[0])
            ? report.current_condition[0]
            : null)
    readonly property var areaInfo: report && report.nearest_area && report.nearest_area[0]
        ? report.nearest_area[0]
        : null
    readonly property var forecastDays: WeatherLabels.buildForecastDays(
        report, dailyForecastReport, Qt.formatDate(new Date(), "yyyy-MM-dd"))
    readonly property string today: Qt.formatDate(new Date(), "yyyy-MM-dd")
    readonly property var todayForecast: WeatherLabels.todayForecast(report, dailyForecastReport, today)
    // The API's own clock for the forecast location, so the strip starts at the
    // hour it is now *there* rather than at midnight.
    readonly property string localNow: (dailyForecastReport && dailyForecastReport.current
        && dailyForecastReport.current.time)
        ? String(dailyForecastReport.current.time).slice(0, 16)
        : ""
    readonly property var todayHourlyForecast: WeatherLabels.openMeteoHourlyForecast(
        dailyForecastReport, localNow)
    readonly property var forecastTimeline: WeatherLabels.buildForecastTimeline(
        report, dailyForecastReport, today)
    readonly property var activities: WeatherLabels.activityForecast(openMeteoCurrent, todayForecast)
    readonly property string reportCountry: areaInfo && areaInfo.country && areaInfo.country[0]
        ? areaInfo.country[0].value
        : ""
    readonly property bool useImperial: WeatherLabels.shouldUseImperial(
        "", Qt.locale().name, reportCountry)

    readonly property string reportLocation: configuredLocation || wttrLocation
        || (areaInfo && areaInfo.areaName && areaInfo.areaName[0] ? areaInfo.areaName[0].value : "")
    readonly property string reportTempNum: current
        ? String(useImperial ? current.temp_F : current.temp_C)
        : ""
    readonly property string tempUnit: "°" + (useImperial ? "F" : "C")
    readonly property string reportFeels: current
        ? WeatherLabels.formatTemp(useImperial ? current.FeelsLikeF : current.FeelsLikeC, useImperial)
        : ""
    readonly property string reportWind: current
        ? (useImperial ? (current.windspeedMiles + " mph") : (current.windspeedKmph + " km/h"))
        : ""
    readonly property string reportHumidity: current ? (current.humidity + "%") : ""

    function refreshDailyForecast(sourceReport) {
        if (dailyForecastProc.running)
            return

        let lat = parseFloat(String(configuredLocationState.latitude))
        let lon = parseFloat(String(configuredLocationState.longitude))
        if (isNaN(lat) || isNaN(lon)) {
            if (!isNaN(root.detectedLatitude) && !isNaN(root.detectedLongitude)) {
                lat = root.detectedLatitude
                lon = root.detectedLongitude
            } else {
                const area = sourceReport && sourceReport.nearest_area && sourceReport.nearest_area[0]
                    ? sourceReport.nearest_area[0]
                    : root.areaInfo
                if (!area)
                    return
                lat = parseFloat(String(area.latitude || ""))
                lon = parseFloat(String(area.longitude || ""))
            }
        }
        if (isNaN(lat) || isNaN(lon))
            return

        dailyForecastProc.command = ["curl", "-fsS", "--max-time", "5",
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + encodeURIComponent(String(lat))
            + "&longitude=" + encodeURIComponent(String(lon))
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
            + "&hourly=temperature_2m,weather_code,is_day"
            + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day"
            + "&forecast_days=6"
            // Yesterday leads the forecast list, as a weather app shows it.
            + "&past_days=1"
            + "&timezone=auto"]
        dailyForecastProc.running = true
    }

    function applyForecast(raw) {
        const text = String(raw || "").trim()
        if (!text)
            return

        let parsed = null
        try {
            parsed = JSON.parse(text)
        } catch (e) {
            parsed = null
        }

        if (!parsed) {
            // Keep whatever is on screen rather than blanking the panel on one
            // malformed response.
            if (root.forecastRetries < root.maxRetries) {
                root.forecastRetries += 1
                Qt.callLater(() => {
                    if (!forecastProc.running)
                        forecastProc.running = true
                })
            }
            return
        }

        report = parsed
        forecastRetries = 0
        root.markUpdated()
        // City, not region: nearest_area[0] carries both, and the region is the
        // province — taking it here replaced the detected city a second after
        // the city had already been shown.
        if (!root.wttrLocation && parsed.nearest_area && parsed.nearest_area[0]
                && parsed.nearest_area[0].areaName && parsed.nearest_area[0].areaName[0])
            wttrLocation = String(parsed.nearest_area[0].areaName[0].value || "")

        root.refreshDailyForecast(parsed)

        if (root.savingLocation && root.savingLocationQueryStarted
                && WeatherLabels.weatherResponseCompletesSave(root.hasConfiguredCoordinates, "wttr"))
            root.cancelEditingLocation()
    }

    function applyDailyForecast(raw) {
        const text = String(raw || "").trim()
        if (!text)
            return

        let parsed = null
        try {
            parsed = JSON.parse(text)
        } catch (e) {
            parsed = null
        }

        if (!parsed) {
            if (root.dailyForecastRetries < root.maxRetries) {
                root.dailyForecastRetries += 1
                Qt.callLater(() => {
                    if (!dailyForecastProc.running)
                        dailyForecastProc.running = true
                })
            }
            return
        }

        dailyForecastReport = parsed
        dailyForecastRetries = 0
        root.markUpdated()

        if (root.savingLocation && root.savingLocationQueryStarted
                && WeatherLabels.weatherResponseCompletesSave(root.hasConfiguredCoordinates, "open-meteo"))
            root.cancelEditingLocation()
    }

    // When the numbers were last refreshed, so a stale panel is visibly stale
    // rather than quietly out of date.
    property string updatedAt: ""

    function markUpdated() {
        const now = new Date()
        updatedAt = Qt.formatTime(now, "HH:mm")
    }

    Process {
        id: forecastProc

        command: ["curl", "-fsS", "--max-time", "10",
            "https://wttr.in/" + root.locationQuery + "?format=j1"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applyForecast(text)
        }
        stderr: StdioCollector {
            waitForEnd: true
        }
    }

    Process {
        id: dailyForecastProc

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applyDailyForecast(text)
        }
        stderr: StdioCollector {
            waitForEnd: true
        }
    }

    // Only the IP-detected place, which wttr.in exposes on its root path.
    // The wttr.in path segment: coordinates when stored, else the encoded name,
    // else nothing at all — which is what makes wttr.in answer from the IP.
    Process {
        id: locationProc

        command: ["curl", "-fsS", "--max-time", "10", "https://wttr.in/?format=%l"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const detected = String(text || "").trim().split(",")[0]
                if (detected.length > 0) {
                    root.wttrLocation = detected
                    root.resolveDetectedLocation()
                }
            }
        }
        stderr: StdioCollector {
            waitForEnd: true
        }
    }

    // wttr.in names the detected place; geocoding that name is what makes the
    // name and the forecast describe the same place.
    function resolveDetectedLocation() {
        const name = String(root.wttrLocation || "").trim()
        if (name.length === 0)
            return
        detectedGeocodeProc.command = ["curl", "-fsS", "--max-time", "6",
            "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(name)
            + "&count=1&language=en&format=json"]
        detectedGeocodeProc.running = true
    }

    Process {
        id: detectedGeocodeProc

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const results = WeatherLabels.parseGeocodingResults(text)
                if (results.length === 0)
                    return
                root.detectedLatitude = results[0].latitude
                root.detectedLongitude = results[0].longitude
                root.refreshDailyForecast(null)
            }
        }
        stderr: StdioCollector {
            waitForEnd: true
        }
    }

    Process {
        id: locationSaveProc

        stdout: StdioCollector {
            waitForEnd: true
        }
        stderr: StdioCollector {
            waitForEnd: true
        }
    }

    Process {
        id: geocodeProc

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const results = WeatherLabels.parseGeocodingResults(text)
                root.locationSuggestions = results
                root.suggestionIndex = 0
                if (root.geocodePendingQuery !== root.geocodeActiveQuery)
                    Qt.callLater(root.startGeocode)
                else
                    root.geocodePendingQuery = ""
            }
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.locationSuggestions = []
                if (root.geocodePendingQuery !== root.geocodeActiveQuery)
                    Qt.callLater(root.startGeocode)
                else
                    root.geocodePendingQuery = ""
            }
        }
    }

    Timer {
        id: geocodeDebounce

        property string query: ""

        interval: 350
        repeat: false
        onTriggered: root.requestGeocode(query)
    }

    // Ten minutes: a forecast that is a quarter hour old is a forecast the user
    // will call wrong, and both APIs answer in well under a second.
    Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // A panel left open still refreshes, without waiting for the next cycle to
    // expire under the user.
    Timer {
        interval: 2 * 60 * 1000
        running: root.open
        repeat: true
        onTriggered: {
            if (root.current && root.current.temp_C !== undefined)
                return
            root.refresh()
        }
    }

    onOpenChanged: {
        if (open)
            Qt.callLater(root.refresh)
    }

    IpcHandler {
        target: "weather"

        function toggle(): void { root.toggle() }
        function open(): void { root.open = true }
        function close(): void { root.close() }
        function refresh(): void { root.refresh() }
        function edit(): void {
            root.open = true
            Qt.callLater(root.startEditingLocation)
        }
    }

    Component.onCompleted: WeatherRuntime.attach(root)
    Component.onDestruction: Qt.callLater(() => WeatherRuntime.detach(root))
}
