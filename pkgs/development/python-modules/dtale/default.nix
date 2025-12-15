{ lib
, buildPythonPackage
, fetchPypi
, flask-compress
, dash-bootstrap-components
, strsimpy
, dash-daq
, missingno
, statsmodels
, setuptools
, lz4
, et-xmlfile
, future
, kaleido
, networkx
, openpyxl
, pkginfo
, scikit-learn
, squarify
, xarray
, xlrd
, beautifulsoup4
, ...
}:

buildPythonPackage rec {
  pname = "dtale";
  version = "3.18.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JiQl+yHsGAJd8FPa4QAsOkgZwXbtpx84yyIG8ex4asY=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    lz4
    et-xmlfile
    future
    kaleido
    networkx
    openpyxl
    pkginfo
    scikit-learn
    squarify
    xarray
    xlrd
    beautifulsoup4
    flask-compress
    dash-bootstrap-components
    strsimpy
    dash-daq
    missingno
    statsmodels
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/man-group/dtale";
    description = "Web Client for Visualizing Pandas Objects";
    license = licenses.lgpl21Only;
  };
}
