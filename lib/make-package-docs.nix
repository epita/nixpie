{ pkgs, lib, nixosConfigurations }:

let
  # Filter main images only (exclude -local, -vm, exam-* variants)
  mainImages = lib.filterAttrs
    (name: _:
      !lib.hasPrefix "exam-" name &&
      !lib.hasSuffix "-vm" name &&
      !lib.hasSuffix "-local" name)
    nixosConfigurations;

  # Sort image names alphabetically
  sortedImageNames = lib.sort (a: b: a < b) (builtins.attrNames mainImages);

  # Extract sorted package list from config
  getPackages = config:
    let
      pkgList = config.environment.systemPackages;
      pkgInfo = pkg: {
        name = pkg.pname or (lib.getName pkg);
        version = pkg.version or "unknown";
      };
      extracted = map pkgInfo pkgList;
    in
    lib.sort (a: b: a.name < b.name) extracted;

  # CSS styles shared across pages
  styles = ''
    :root {
      --primary: #5277C3;
      --bg: #fafafa;
      --border: #ddd;
    }
    * { box-sizing: border-box; }
    body {
      font-family: system-ui, -apple-system, sans-serif;
      margin: 0;
      padding: 2rem;
      background: var(--bg);
      line-height: 1.5;
    }
    .container { max-width: 1200px; margin: 0 auto; }
    h1 { color: var(--primary); margin-top: 0; }
    a { color: var(--primary); text-decoration: none; }
    a:hover { text-decoration: underline; }
    table {
      width: 100%;
      border-collapse: collapse;
      background: white;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    th, td {
      padding: 0.75rem 1rem;
      text-align: left;
      border-bottom: 1px solid var(--border);
    }
    th {
      background: var(--primary);
      color: white;
      font-weight: 500;
    }
    tr:hover { background: #f5f5f5; }
    .version { font-family: monospace; color: #666; }
    .count { color: #666; font-size: 0.9rem; }
    footer {
      margin-top: 2rem;
      padding-top: 1rem;
      border-top: 1px solid var(--border);
      color: #888;
      font-size: 0.85rem;
    }
  '';

  # Generate per-image HTML page
  mkImagePage = imageName: config:
    let
      packages = getPackages config;
      packageRows = lib.concatMapStringsSep "\n" (pkg: ''
        <tr>
          <td>${lib.escapeXML pkg.name}</td>
          <td class="version">${lib.escapeXML pkg.version}</td>
        </tr>'') packages;
    in
    pkgs.writeText "${imageName}.html" ''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${imageName} - NixPIE Packages</title>
        <style>${styles}</style>
      </head>
      <body>
        <div class="container">
          <p><a href="index.html">&larr; Back to all images</a></p>
          <h1>${imageName}</h1>
          <p class="count">${toString (builtins.length packages)} packages</p>
          <table>
            <thead>
              <tr>
                <th>Package</th>
                <th>Version</th>
              </tr>
            </thead>
            <tbody>
              ${packageRows}
            </tbody>
          </table>
          <footer>
            Generated from <a href="https://gitlab.cri.epita.fr/forge/infra/nixpie">nixpie</a>
          </footer>
        </div>
      </body>
      </html>
    '';

  # Generate index page
  mkIndexPage =
    let
      imageRows = lib.concatMapStringsSep "\n"
        (name:
          let
            packages = getPackages mainImages.${name}.config;
          in
          ''
            <tr>
              <td><a href="${name}.html">${name}</a></td>
              <td class="count">${toString (builtins.length packages)}</td>
            </tr>'')
        sortedImageNames;
    in
    pkgs.writeText "index.html" ''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>NixPIE Package Documentation</title>
        <style>${styles}</style>
      </head>
      <body>
        <div class="container">
          <h1>NixPIE Package Documentation</h1>
          <p>Package lists for EPITA computer room images.</p>
          <table>
            <thead>
              <tr>
                <th>Image</th>
                <th>Packages</th>
              </tr>
            </thead>
            <tbody>
              ${imageRows}
            </tbody>
          </table>
          <footer>
            Generated from <a href="https://gitlab.cri.epita.fr/forge/infra/nixpie">nixpie</a>
          </footer>
        </div>
      </body>
      </html>
    '';

in
pkgs.runCommand "package-docs" { } ''
  mkdir -p $out
  cp ${mkIndexPage} $out/index.html
  ${lib.concatMapStringsSep "\n"
    (name: "cp ${mkImagePage name mainImages.${name}.config} $out/${name}.html")
    sortedImageNames}
''
