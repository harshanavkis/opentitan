with import <nixpkgs> {};
with python39Packages;

let

  lizard = buildPythonPackage rec{
    name = "lizard";
	version = "1.17.9";

	src = pkgs.fetchurl {
	  url = "https://github.com/terryyin/lizard/archive/refs/tags/${version}.tar.gz";
	  sha256 = "22559181a556bdda2577420f4f6a54428109b0af9b832d77f08fcaf26b4019e3";
    };

	doCheck = false;
  };

  pydriller = buildPythonPackage rec{
    name = "pydriller";
	version = "2.1";

	src = pkgs.fetchurl {
	  url = "https://github.com/ishepard/pydriller/archive/refs/tags/${version}.tar.gz";
	  sha256 = "e110d14a5d9e8eebcaf8c9a8e16820e0bab19d49c10b7fb5393f4a18dc6bdac5";
    };

	buildInputs = with self; [ lizard pytz GitPython types-pytz ];

	doCheck = false;
  };

  meson = buildPythonPackage rec{
    name = "meson";
	version = "0.57.1";

	src = pkgs.fetchurl {
	  url = "https://github.com/mesonbuild/meson/releases/download/${version}/meson-${version}.tar.gz";
	  sha256 = "sha256-cuHHgrqb2iBPSh7Vf5jQJ9e265QUxyPuu9bsfxlVyKY=";
    };

	doCheck = false;
  };

  jinja2 = buildPythonPackage rec{
    name = "jinja2";
	version = "2.11.3";

	src = pkgs.fetchurl {
	  url = "https://github.com/pallets/jinja/archive/refs/tags/${version}.tar.gz";
	  sha256 = "sha256-S+RKnlX7BpNHshfS1m1R2LCpfy92mFuQYwu08xfrBCo=";
    };

	buildInputs = with self; [ markupsafe ];
  };

  vunit_hdl = buildPythonPackage rec{
    name = "vunit_hdl";
	version = "4.6.0";

	src = pkgs.fetchurl {
	  url = "https://github.com/VUnit/vunit/archive/refs/tags/v${version}.tar.gz";
	  sha256 = "sha256-a601b5XfmtPaXoiWtFeQLC8xMe/0LbpuyLDLwmbTwBk=";
    };

	buildInputs = with self; [ colorama ];

	doCheck = false;
  };

  markupsafe = buildPythonPackage rec{
    name = "markupsafe";
	version = "2.0.1";

	src = pkgs.fetchurl {
	  url = "https://github.com/pallets/markupsafe/archive/refs/tags/2.0.1.tar.gz";
	  sha256 = "sha256-JJowJouuXAmC7k8xq7cSZXfANgIJKg8sZLBqT2gXazA=";
    };

	buildInputs = with self; [ ];

	# doCheck = false;
  };

  edalize = buildPythonPackage rec{
    name = "edalize";
    
	src = pkgs.fetchgit {
	  url = "https://github.com/lowRISC/edalize.git";
	  rev = "5ae2c3e1ca306e27d81ce5fcc769f62cb7ac42d0";
	  sha256 = "sha256-iIf7bUBE2SeS/TByUNL9wI1LswlHTmgHYGJltWXNUWE=";
    };

	nativeBuildInputs = with self; [ jinja2 pytest markupsafe vunit_hdl colorama pyyaml setuptools_scm pandas ];
    leaveDotGit = true;
  };

  zipfile2 = buildPythonPackage rec{
    name = "zipfile2";
    version = "0.0.12";

    src = pkgs.fetchFromGitHub {
      owner = "cournape";
      repo = "zipfile2";
      rev = "1de7d262af43362177fb299fc6f4f3d012e8843a";
      sha256 = "sha256-nQkJVosgp1etchVzpnPc9KFnfyCon1Iag3euN+YSGMg=";
      fetchSubmodules = true;
      leaveDotGit = true;
    };

	doCheck = false;
  };

  okonomiyaki = buildPythonPackage rec{
    name = "okonomiyaki";
	version = "1.3.1";

	src = pkgs.fetchFromGitHub {
	  owner = "enthought";
	  repo = "okonomiyaki";
	  rev = "df23b5538c8b73585dfcdd00029321f0503fb8bd";
	  sha256 = "sha256-L4cFQiy2TWPdEfUWImnpA3L8sMGJ/w7DnrJFcA3sgbU=";
	  fetchSubmodules = true;
	  leaveDotGit = true;
    };

	buildInputs = with self; [ attrs six jsonschema zipfile2 ];

	doCheck = false;
  };

  simplesat = buildPythonPackage rec{
    name = "simplesat";
	version = "0.8.2";

	src = pkgs.fetchFromGitHub {
	  owner = "enthought";
	  repo = "sat-solver";
	  rev = "4ce881644c872e629358e31f37bc8d099ce42591";
	  sha256 = "sha256-6mYFqXFRLEOVV4yv/BlIVAnvvCksDAVgQFxshYpZUK4=";
	  fetchSubmodules = true;
	  leaveDotGit = true;
    };

	buildInputs = with self; [ attrs okonomiyaki six jsonschema zipfile2 ];

	doCheck = false;
  };

  fusesoc = buildPythonPackage rec{
    name = "fusesoc";

    
    src = pkgs.fetchgit {
	  url = "https://github.com/lowRISC/fusesoc.git";
      rev = "c64ca392382b0c432c893d5ce4a93b77af213fdf";
      sha256 = "sha256-HFrx6vjthNbhrIeV4vNW3YmmqBwqb6lX8lu0dcmQnQM=";
    };

    nativeBuildInputs = with self; [ git pyyaml setuptools_scm edalize simplesat jinja2 markupsafe attrs okonomiyaki jsonschema zipfile2 ];
    leaveDotGit = true;

    SETUPTOOLS_SCM_PRETEND_VERSION = 0.2;

    doCheck = false;
  };

  mypython = python39.withPackages(ps: with ps; [
    hjson
    libcst
	Mako
	pycryptodome
	pyelftools
	pytest
	pytest-timeout
	pyyaml
	tabulate

	# dv_sim dependencies
	# ignored for now

	# Dependencies: check_dif_statuses.py
    pydriller
    termcolor

	# Linters
    # ignored for now

	# Type stubs for mypy checking.
	# ignored for now

    # Dependency of sw/host/vendor/google_verible_verilog_syntax_py
	anytree

	# To be removed with Meson.
    # Minimum matches version in meson.build
    meson

	# Development version with OT-specific changes
	okonomiyaki
	simplesat
	jinja2
	fusesoc
	edalize

	# Development version of ChipWhisperer toolchain
	# ig for now
  ]);

in stdenv.mkDerivation rec {
  name = "opentitan-env";
  nativeBuildInputs = [
    # for the native platform
  ];

  buildInputs = [
    # for dependencies required at run time
	# usually for a foreign, non-native platform
    autoconf
	bison
	cmake
	curl
	doxygen
	flex
	gcc
	gdb
	git
	go
	lcov
	libelf
	libftdi1
    ncurses5
	openssl
	udev
	libusb1
	lsb-release
    ninja
	perl
	pkgconf
    mypython
	python39Packages.pip
	python39Packages.setuptools
	python39Packages.wheel
	srecord
	tree
	libxslt
	zlib
	xz
	pkg-config
	verilator
  ];
}
