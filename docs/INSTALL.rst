NLSR Installation Instructions
==============================

.. toctree::
..

Prerequisites
-------------

- `NFD <https://named-data.net/doc/NFD/>`_ and its dependencies

  Refer to `Getting started with NFD <https://named-data.net/doc/NFD/current/INSTALL.html>`_
  for detailed installation and running instruction.

- PSync library

  Download the PSync library and build it according to the instructions available at
  https://github.com/named-data/PSync#build

- [Optional] ChronoSync library

  For testing purposes, NLSR can be optionally built with Chronosync support. Download
  the ChronoSync library and build it according to the instructions available at
  https://github.com/named-data/ChronoSync#build

- [Optional] SVS library

  NLSR can be used with State Vector Sync as the underlying Sync protocol. Download
  the ndn-svs library and build it according to the instructions available at
  https://github.com/named-data/ndn-svs

Build
-----

Execute the following commands to build NLSR:

.. code-block:: sh

    ./waf configure
    ./waf
    sudo ./waf install

Refer to ``./waf --help`` for more options that can be used during the configure stage and
how to properly configure NLSR.

If your pkgconfig path is not set properly, you can do the following before running ``./waf
configure``:

.. code-block:: sh

    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    # or
    export PKG_CONFIG_PATH=/path/to/pkgconfig/on/your/machine

If ChronoSync support is desired, NLSR needs to be configured with the following option:

.. code-block:: sh

    ./waf configure --with-chronosync
