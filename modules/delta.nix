{ pkgs }:

{
  enable = true;
  enableGitIntegration = true;
  options = {
    features = "tokyonight";
    side-by-side = true;
    line-numbers = true;

    tokyonight = {
      syntax-theme = "none";
      commit-decoration-style = "bold #7aa2f7 box ul";
      file-style = "bold #7aa2f7";
      file-decoration-style = "none";
      hunk-header-decoration-style = "#7dcfff box";
      hunk-header-file-style = "#bb9af7";
      hunk-header-line-number-style = "bold #7dcfff";
      hunk-header-style = "file line-number syntax";

      minus-style = "syntax #37222c";
      minus-emph-style = "syntax #f7768e";
      minus-non-emph-style = "syntax auto";

      plus-style = "syntax #20303b";
      plus-emph-style = "syntax #9ece6a";
      plus-non-emph-style = "syntax auto";

      line-numbers-minus-style = "#f7768e";
      line-numbers-plus-style = "#9ece6a";
      line-numbers-left-style = "#565f89";
      line-numbers-right-style = "#565f89";
      line-numbers-zero-style = "#3b4261";
    };
  };
}
