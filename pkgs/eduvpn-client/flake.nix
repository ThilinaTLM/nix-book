{
  description = "EduVPN NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = let
      # Fetch the wheel for eduvpn-common
      eduvpnCommonWheel = nixpkgs.legacyPackages.x86_64-linux.fetchurl {
        url = "https://files.pythonhosted.org/packages/69/a9/5d05f3953645e6f62e3eb63d953b343e8b5738c79436137a474d600723b3/eduvpn_common-1.1.2-py3-none-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_28_x86_64.whl";
        sha256 = "47c292a169a89a9c1472fcf9b90fab595b6d639cf5eb4ea00c21c637f65f615f";
      };

      # Manually package eduvpn-common from the wheel
      eduvpnCommon = nixpkgs.legacyPackages.x86_64-linux.python310Packages.buildPythonPackage rec {
        pname = "eduvpn-common";
        version = "1.1.2";
        src = eduvpnCommonWheel;
        format = "wheel";
        propagatedBuildInputs = with nixpkgs.legacyPackages.x86_64-linux.python310Packages; [ pygobject3 ];
      };

      # Fetch the wheel for eduvpn-client
      eduvpnClientWheel = nixpkgs.legacyPackages.x86_64-linux.fetchurl {
        url = "https://files.pythonhosted.org/packages/60/5f/64736e11051fc821bca29c277b21b843992316a8402cfd890cd7874e6c50/eduvpn_client-4.1.3-py2.py3-none-any.whl";
        sha256 = "b41d8ab26ad5261938d4ee98ccae24c4fc1c7862eb0d970668bc692330ac2346";
      };

      # Manually package eduvpn-client from the wheel
      eduvpnClient = nixpkgs.legacyPackages.x86_64-linux.python310Packages.buildPythonPackage rec {
        pname = "eduvpn-client";
        version = "4.1.3";
        src = eduvpnClientWheel;
        format = "wheel";
        propagatedBuildInputs = with nixpkgs.legacyPackages.x86_64-linux.python310Packages; [ eduvpnCommon pygobject3 ];
      };

      # Python with specific packages
      pythonWithPackages = nixpkgs.legacyPackages.x86_64-linux.python310.withPackages (ps: [
        eduvpnClient
        ps.pygobject3
        ps.wheel
        ps.pytest
        ps.pycodestyle
        ps.mypy
        ps.types-setuptools
        ps.setuptools
        ps.dbus-python
      ]);

      # Access the necessary packages directly
      pkgConfig = nixpkgs.legacyPackages.x86_64-linux.pkg-config;
      libsecret = nixpkgs.legacyPackages.x86_64-linux.libsecret;
      gtk3 = nixpkgs.legacyPackages.x86_64-linux.gtk3;
      libnotify = nixpkgs.legacyPackages.x86_64-linux.libnotify;
      gobjectIntrospection = nixpkgs.legacyPackages.x86_64-linux.gobject-introspection;
      dbusGlib = nixpkgs.legacyPackages.x86_64-linux.dbus-glib;
      networkmanagerOpenvpn = nixpkgs.legacyPackages.x86_64-linux.networkmanager-openvpn;
      networkmanagerDev = nixpkgs.legacyPackages.x86_64-linux.networkmanager.dev;

    in {
      # Custom python package with dependencies
      eduvpnClientPackage = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation {
        name = "eduvpn-client";
        buildInputs = [
            pythonWithPackages
            pkgConfig
            libsecret
            gtk3
            libnotify
            gobjectIntrospection
            dbusGlib
            networkmanagerOpenvpn
            networkmanagerDev
        ];
      };

      # Default package
      default = self.packages.x86_64-linux.eduvpnClientPackage;
    };
  };
}
