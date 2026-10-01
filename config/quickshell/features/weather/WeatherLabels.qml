pragma Singleton

import QtQuick

// Data shaping for the weather panel: parsing the two API responses, picking
// units, and mapping weather codes to glyphs. Pure functions — the fetching and
// the UI live elsewhere.
QtObject {

    // ---------- Location state ----------
    //
    // weather.json holds {"name", "latitude", "longitude"} (see
    // qs-weather-location, which owns the format). Missing, blank, or
    // unparseable means the location is auto-detected from the IP address.

    function parseLocationFile(raw) {
        let data
        try {
            data = JSON.parse(String(raw || ""))
        } catch (e) {
            return { name: "", latitude: null, longitude: null }
        }
        if (!data || typeof data !== "object")
            return { name: "", latitude: null, longitude: null }

        const latitude = parseFloat(data.latitude)
        const longitude = parseFloat(data.longitude)
        const hasCoordinates = !isNaN(latitude) && !isNaN(longitude)
        return {
            name: typeof data.name === "string" ? data.name.trim() : "",
            latitude: hasCoordinates ? latitude : null,
            longitude: hasCoordinates ? longitude : null
        }
    }

    // wttr.in path segment: exact coordinates when both are present, the
    // URL-encoded name as a fallback, empty for IP auto-detect.
    function wttrLocationQuery(name, latitude, longitude) {
        const lat = parseFloat(String(latitude))
        const lon = parseFloat(String(longitude))
        if (!isNaN(lat) && !isNaN(lon))
            return lat + "," + lon
        const place = String(name || "").trim()
        return place === "" ? "" : encodeURIComponent(place)
    }

    // ipwho.is response, used to name and locate the IP-detected place when no
    // location is stored. wttr.in can name the place but not give coordinates
    // this shell can cache, and the forecast request needs coordinates.
    function parseIpLocation(raw) {
        let data
        try {
            data = JSON.parse(String(raw || "{}"))
        } catch (e) {
            return null
        }
        if (!data || data.success === false)
            return null

        const latitude = parseFloat(data.latitude)
        const longitude = parseFloat(data.longitude)
        if (isNaN(latitude) || isNaN(longitude))
            return null

        const name = [data.city, data.region, data.country]
            .map(part => String(part || "").trim())
            .find(part => part.length > 0) || ""
        return { name: name, latitude: latitude, longitude: longitude }
    }

    // Open-Meteo geocoding response → suggestion rows.
    function parseGeocodingResults(raw) {
        let data
        try {
            data = JSON.parse(String(raw || "{}"))
        } catch (e) {
            return []
        }
        const results = data ? data.results : null
        if (!results || !results.length)
            return []

        const out = []
        for (let i = 0; i < results.length; i++) {
            const r = results[i]
            if (!r || !r.name || r.latitude === undefined || r.longitude === undefined)
                continue
            out.push({
                name: String(r.name),
                description: [r.admin1, r.country].filter(part => !!part).join(", "),
                latitude: r.latitude,
                longitude: r.longitude
            })
        }
        return out
    }

    function locationCommit(text, suggestions, selectedIndex) {
        const name = String(text || "").trim()
        if (name === "")
            return { name: "", latitude: null, longitude: null }

        const choices = suggestions || []
        const index = Math.max(0, Math.min(parseInt(selectedIndex, 10) || 0, choices.length - 1))
        if (choices[index])
            return choices[index]

        return { name: name, latitude: null, longitude: null }
    }

    // ---------- Units ----------

    function normalizedUnit(value) {
        return String(value || "").trim().toLowerCase()
    }

    function localeUsesImperial(localeName) {
        const name = String(localeName || "").replace(".", "_")
        return /^en[_-]US($|[_.-])/.test(name)
            || /^en[_-]LR($|[_.-])/.test(name)
            || /^my($|[_.-])/.test(name)
    }

    function countryUsesImperial(countryName) {
        const country = String(countryName || "").trim().replace(/[._-]+/g, " ").toLowerCase()
        if (!country)
            return null
        if (country === "us" || country === "usa"
                || country === "united states" || country === "united states of america")
            return true
        if (country === "liberia" || country === "myanmar" || country === "burma")
            return true
        return false
    }

    function shouldUseImperial(unitOverride, localeName, countryName) {
        const unit = normalizedUnit(unitOverride)
        if (unit === "imperial")
            return true
        if (unit === "metric")
            return false

        const byCountry = countryUsesImperial(countryName)
        if (byCountry !== null)
            return byCountry

        return localeUsesImperial(localeName)
    }

    // ---------- Values ----------

    function isFutureForecastDate(dateString, todayString) {
        if (!dateString)
            return false
        return String(dateString).slice(0, 10) > String(todayString || "")
    }

    function roundedTemp(value) {
        if (value === undefined || value === null || value === "")
            return ""
        const n = parseFloat(String(value))
        return isNaN(n) ? "" : String(Math.round(n))
    }

    function celsiusToFahrenheit(value) {
        if (value === undefined || value === null || value === "")
            return ""
        const n = parseFloat(String(value))
        return isNaN(n) ? "" : (n * 9 / 5) + 32
    }

    function formatTemp(value, useImperial) {
        if (value === undefined || value === null || value === "")
            return ""
        return value + "°" + (useImperial ? "F" : "C")
    }

    function dayName(dateString) {
        if (!dateString)
            return ""
        const d = new Date(dateString + "T12:00:00")
        if (isNaN(d.getTime()))
            return ""
        return Qt.formatDate(d, "dddd")
    }

    // Bare degree value (no unit letter), for the forecast row.
    function bareTempForDay(day, kind, useImperial) {
        if (!day)
            return ""
        const value = useImperial
            ? (kind === "max" ? day.maxtempF : day.mintempF)
            : (kind === "max" ? day.maxtempC : day.mintempC)
        if (value === undefined || value === null || value === "")
            return ""
        return value + "°"
    }

    // ---------- Forecast ----------

    function openMeteoForecastDays(dailyForecastReport, todayString) {
        const daily = dailyForecastReport && dailyForecastReport.daily ? dailyForecastReport.daily : null
        if (!daily || !daily.time)
            return []

        const result = []
        for (let i = 0; i < daily.time.length && result.length < 3; i++) {
            const date = daily.time[i]
            if (!isFutureForecastDate(date, todayString))
                continue

            const maxC = daily.temperature_2m_max ? daily.temperature_2m_max[i] : ""
            const minC = daily.temperature_2m_min ? daily.temperature_2m_min[i] : ""
            result.push({
                date: date,
                maxtempC: roundedTemp(maxC),
                mintempC: roundedTemp(minC),
                maxtempF: roundedTemp(celsiusToFahrenheit(maxC)),
                mintempF: roundedTemp(celsiusToFahrenheit(minC)),
                openMeteoWeatherCode: daily.weather_code ? daily.weather_code[i] : null
            })
        }
        return result
    }

    function wttrNextForecastDays(report, todayString) {
        const days = report && report.weather ? report.weather : []
        const result = []
        for (let i = 0; i < days.length && result.length < 3; i++) {
            if (isFutureForecastDate(days[i].date, todayString))
                result.push(days[i])
        }
        return result
    }

    function buildForecastDays(report, dailyForecastReport, todayString) {
        const days = openMeteoForecastDays(dailyForecastReport, todayString)
        return days.length > 0 ? days : wttrNextForecastDays(report, todayString)
    }

    // Open-Meteo answers far faster than wttr.in and bundles current conditions
    // with the daily forecast, so it is the preferred source when it is
    // available. Normalised to wttr's current_condition shape so the panel can
    // read either source the same way. Open-Meteo is metric.
    function openMeteoCurrentCondition(dailyForecastReport) {
        const current = dailyForecastReport && dailyForecastReport.current ? dailyForecastReport.current : null
        if (!current || current.temperature_2m === undefined || current.temperature_2m === null)
            return null
        return {
            temp_C: roundedTemp(current.temperature_2m),
            temp_F: roundedTemp(celsiusToFahrenheit(current.temperature_2m)),
            FeelsLikeC: roundedTemp(current.apparent_temperature),
            FeelsLikeF: roundedTemp(celsiusToFahrenheit(current.apparent_temperature)),
            windspeedKmph: roundedTemp(current.wind_speed_10m),
            windspeedMiles: roundedTemp(current.wind_speed_10m * 0.621371),
            humidity: roundedTemp(current.relative_humidity_2m),
            openMeteoWeatherCode: current.weather_code,
            isDay: current.is_day
        }
    }

    function weatherResponseCompletesSave(hasConfiguredCoordinates, source) {
        return hasConfiguredCoordinates ? source === "open-meteo" : source === "wttr"
    }

    // ---------- Today, hourly, timeline ----------

    // Yesterday plus today and the days after, for the forecast list. The daily
    // block starts at yesterday on purpose: a weather app shows the day that just
    // happened next to the ones that are coming.
    function openMeteoForecastTimeline(dailyForecastReport, todayString) {
        const daily = dailyForecastReport && dailyForecastReport.daily ? dailyForecastReport.daily : null
        if (!daily || !daily.time)
            return []

        const yesterday = new Date(String(todayString || "") + "T12:00:00")
        if (isNaN(yesterday.getTime()))
            return []
        yesterday.setDate(yesterday.getDate() - 1)
        const yesterdayString = Qt.formatDate(yesterday, "yyyy-MM-dd")

        const result = []
        for (let i = 0; i < daily.time.length && result.length < 8; i++) {
            const date = String(daily.time[i]).slice(0, 10)
            if (date < yesterdayString)
                continue
            const maxC = daily.temperature_2m_max ? daily.temperature_2m_max[i] : ""
            const minC = daily.temperature_2m_min ? daily.temperature_2m_min[i] : ""
            result.push({
                date: date,
                maxtempC: roundedTemp(maxC),
                mintempC: roundedTemp(minC),
                maxtempF: roundedTemp(celsiusToFahrenheit(maxC)),
                mintempF: roundedTemp(celsiusToFahrenheit(minC)),
                openMeteoWeatherCode: daily.weather_code ? daily.weather_code[i] : null,
                precipitationProbability: daily.precipitation_probability_max
                    ? daily.precipitation_probability_max[i]
                    : null
            })
        }
        return result
    }

    function openMeteoTodayForecast(dailyForecastReport, todayString) {
        const daily = dailyForecastReport && dailyForecastReport.daily ? dailyForecastReport.daily : null
        if (!daily || !daily.time)
            return null

        for (let i = 0; i < daily.time.length; i++) {
            if (String(daily.time[i]).slice(0, 10) !== String(todayString || ""))
                continue
            const maxC = daily.temperature_2m_max ? daily.temperature_2m_max[i] : ""
            const minC = daily.temperature_2m_min ? daily.temperature_2m_min[i] : ""
            return {
                date: daily.time[i],
                maxtempC: roundedTemp(maxC),
                mintempC: roundedTemp(minC),
                maxtempF: roundedTemp(celsiusToFahrenheit(maxC)),
                mintempF: roundedTemp(celsiusToFahrenheit(minC)),
                openMeteoWeatherCode: daily.weather_code ? daily.weather_code[i] : null,
                precipitationProbability: daily.precipitation_probability_max
                    ? daily.precipitation_probability_max[i]
                    : null
            }
        }
        return null
    }

    function wttrTodayForecast(report, todayString) {
        const days = report && report.weather ? report.weather : []
        for (let i = 0; i < days.length; i++) {
            if (String(days[i].date).slice(0, 10) === String(todayString || ""))
                return days[i]
        }
        return null
    }

    function todayForecast(report, dailyForecastReport, todayString) {
        return openMeteoTodayForecast(dailyForecastReport, todayString)
            || wttrTodayForecast(report, todayString)
    }

    // The next twelve hours from now, crossing midnight. An earlier
    // today-only filter cut the strip off at 23:00, so the day check is gone;
    // the API's own current.time is "now", in the forecast location's timezone
    // rather than the shell's.
    function openMeteoHourlyForecast(dailyForecastReport, localNow) {
        const hourly = dailyForecastReport && dailyForecastReport.hourly ? dailyForecastReport.hourly : null
        if (!hourly || !hourly.time)
            return []

        const from = String(localNow || "").slice(0, 16)

        const result = []
        for (let i = 0; i < hourly.time.length && result.length < 12; i++) {
            const timestamp = String(hourly.time[i])
            if (from.length === 16 && timestamp.slice(0, 16) < from)
                continue
            const tempC = hourly.temperature_2m ? hourly.temperature_2m[i] : ""
            result.push({
                time: timestamp,
                tempC: roundedTemp(tempC),
                tempF: roundedTemp(celsiusToFahrenheit(tempC)),
                openMeteoWeatherCode: hourly.weather_code ? hourly.weather_code[i] : null,
                isDay: hourly.is_day ? hourly.is_day[i] : 1
            })
        }
        return result
    }

    // Yesterday through today and the days after, from whichever source has it.
    function buildForecastTimeline(report, dailyForecastReport, todayString) {
        const days = openMeteoForecastTimeline(dailyForecastReport, todayString)
        if (days.length > 0)
            return days
        const wttrDays = report && report.weather ? report.weather : []
        const result = []
        for (let i = 0; i < wttrDays.length && result.length < 6; i++) {
            if (String(wttrDays[i].date).slice(0, 10) >= String(todayString || ""))
                result.push(wttrDays[i])
        }
        return result
    }

    function forecastDayLabel(dateString, todayString) {
        const yesterday = new Date(String(todayString || "") + "T12:00:00")
        if (isNaN(yesterday.getTime()))
            return dayName(dateString).slice(0, 3).toUpperCase()
        yesterday.setDate(yesterday.getDate() - 1)

        const date = String(dateString).slice(0, 10)
        if (date === Qt.formatDate(yesterday, "yyyy-MM-dd"))
            return "YESTERDAY"
        if (date === String(todayString || ""))
            return "TODAY"
        return dayName(dateString).slice(0, 3).toUpperCase()
    }

    // Yesterday has no forecast to report, so its detail columns stay empty.
    function showDailyDetails(dateString, todayString) {
        return forecastDayLabel(dateString, todayString) !== "YESTERDAY"
    }

    function forecastPrecipitation(day) {
        if (!day || day.precipitationProbability === undefined
                || day.precipitationProbability === null || day.precipitationProbability === "")
            return ""
        return Math.round(Number(day.precipitationProbability)) + "% rain"
    }

    function hourlyTime(hour) {
        return hour && hour.time ? String(hour.time).slice(11, 16) : ""
    }

    function hourlyTemperature(hour, useImperial) {
        if (!hour)
            return ""
        return (useImperial ? hour.tempF : hour.tempC) + "°"
    }

    // ---------- Activity forecasts ----------
    //
    // Derived from today's rain chance, wind and temperature: no extra API, and
    // it answers the question people actually ask of a forecast ("can I go out?")
    // rather than restating the numbers.
    function activityForecast(current, today) {
        const code = current && current.openMeteoWeatherCode !== undefined
            ? Number(current.openMeteoWeatherCode)
            : 0
        const rain = today && today.precipitationProbability !== undefined
            && today.precipitationProbability !== null
            ? Number(today.precipitationProbability)
            : 0
        const wind = current
            ? Number(current.windspeedKmph || 0)
            : 0
        const temp = current ? Number(current.temp_C === undefined ? 20 : current.temp_C) : 20
        const wet = rain >= 45 || code >= 51
        const storm = code >= 95

        function entry(name, symbol, good, message) {
            return { name: name, symbol: symbol, status: good ? "Good" : "Poor", message: message }
        }

        return [
            entry("Hiking", "⛰", !wet && !storm && wind < 35 && temp > 8 && temp < 34,
                wet || storm ? "Rain is expected today" : "Conditions are challenging today"),
            entry("Cycling", "󰥔", !wet && !storm && wind < 28 && temp > 10 && temp < 32,
                wet || storm ? "Poor weather for cycling" : "Wind or temperature may be uncomfortable"),
            entry("Running", "󰓜", !storm && rain < 60 && temp > 5 && temp < 30,
                storm || rain >= 60 ? "Rain is expected today" : "Warm or windy conditions"),
            entry("Camping", "󰛖", !wet && !storm && rain < 35 && temp > 8 && temp < 30,
                wet || storm ? "Rain is expected today" : "Check wind and overnight temperature")
        ]
    }

    // ---------- Glyphs ----------
    //
    // wttr.in codes mapped onto Nerd Font weather glyphs. Open-Meteo's WMO codes
    // are folded onto the closest wttr code so there is one table.

    function iconForCode(code, night) {
        switch (parseInt(String(code || "0"), 10)) {
        case 113:
            return night ? "" : ""
        case 116:
            return night ? "" : ""
        case 119:
        case 122:
            return ""
        case 143:
        case 248:
        case 260:
            return night ? "" : ""
        case 176:
        case 263:
        case 353:
            return night ? "" : ""
        case 179:
        case 227:
        case 230:
        case 323:
        case 326:
        case 368:
            return night ? "" : ""
        case 182:
        case 185:
        case 281:
        case 284:
        case 311:
        case 314:
        case 317:
        case 320:
        case 350:
        case 362:
        case 365:
        case 374:
        case 377:
            return ""
        case 200:
        case 386:
        case 389:
        case 392:
        case 395:
            return ""
        case 266:
        case 293:
        case 296:
        case 299:
        case 302:
        case 305:
        case 308:
        case 356:
        case 359:
            return ""
        case 329:
        case 332:
        case 335:
        case 338:
        case 371:
            return ""
        default:
            return ""
        }
    }

    function iconForOpenMeteoCode(code, night) {
        const c = parseInt(String(code || "0"), 10)
        if (c === 0)
            return iconForCode(113, night)
        if (c === 1 || c === 2)
            return iconForCode(116, night)
        if (c === 3)
            return iconForCode(119, night)
        if (c === 45 || c === 48)
            return iconForCode(143, night)
        if (c === 51 || c === 53 || c === 55 || c === 56 || c === 57 || c === 61)
            return iconForCode(266, night)
        if (c === 63 || c === 65 || c === 66 || c === 67 || c === 80 || c === 81 || c === 82)
            return iconForCode(308, night)
        if (c === 71 || c === 73 || c === 75 || c === 77 || c === 85 || c === 86)
            return iconForCode(338, night)
        if (c === 95 || c === 96 || c === 99)
            return iconForCode(389, night)
        return iconForCode(119, night)
    }

    function currentIcon(current, fallback) {
        if (!current)
            return fallback || ""
        if (current.openMeteoWeatherCode !== undefined && current.openMeteoWeatherCode !== null)
            return iconForOpenMeteoCode(current.openMeteoWeatherCode, Number(current.isDay) === 0)
        if (current.weatherCode !== undefined && current.weatherCode !== null)
            return iconForCode(current.weatherCode, false)
        return fallback || ""
    }

    // wttr.in has no day/night flag, so its icon only ever fills an empty
    // initial state — it never replaces a day/night-aware icon.
    function provisionalCurrentIcon(current, resolvedIcon) {
        return resolvedIcon || currentIcon(current, "")
    }

    // Representative icon for a forecast day: the hourly entry nearest noon.
    function dayIcon(day) {
        if (!day)
            return ""
        if (day.openMeteoWeatherCode !== undefined && day.openMeteoWeatherCode !== null)
            return iconForOpenMeteoCode(day.openMeteoWeatherCode)
        if (!day.hourly || day.hourly.length === 0)
            return ""

        let best = day.hourly[0]
        let bestDistance = 9999
        for (let i = 0; i < day.hourly.length; i++) {
            const t = parseInt(String(day.hourly[i].time || "0"), 10)
            const distance = Math.abs(t - 1200)
            if (distance < bestDistance) {
                bestDistance = distance
                best = day.hourly[i]
            }
        }
        return iconForCode(best.weatherCode, false)
    }
}
