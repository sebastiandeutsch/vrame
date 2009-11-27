VRAME
=====

VRAME is a CMS (content management system) based on Ruby on Rails.
It is designed to run as a Rails Engine on top of your existing Rails app.

Philosophy
==========

VRAME does not force you into any kind of predefined, inappropriate structure.
It allows you to build and use your own information architecture.

In order to integrate VRAME with your app, it provides a few Rails models which fulfill certain tasks:

* Categories act like folders. They include schemas for their documents.
* Documents act as endpoints. They can be represented as a custom HTML template or as JSON for external APIs.
* Assets act as storage for files, mainly images. They care about thumbnail creation, video conversion, etc.
* Collections act as containers for multiple assets.

Feature Overview
----------------

* Schema Builder: Create a schema for underlying documents
* Rich types for appropriate information representation
 * Google Maps integration
 * Images & thumbnail creation
 * Video conversion
* User management _(in progress)_

Installation
============

The following versions are required for VRAME:

* Rails >= 2.3.4
* Ruby >= 1.8.6
* MySQL >= 5.x

Adding VRAME to your Rails App
------------------------------

Currently a repository only
No gem
No version numbers yet
But that's planned

    cd your_rails_app
    git submodule add git://github.com/sebastiandeutsch/vrame.git vendor/plugins/vrame
    git submodule add git://github.com/sebastiandeutsch/nine_auth_engine.git vendor/plugins/nine_auth_engine

Initialize VRAME 
----------------

    sudo rake gems:install
    rake vrame:bootstrap

Copyright (c) 2009 9elements.com, released under the MIT license
