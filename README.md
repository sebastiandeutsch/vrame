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

Currently VRAME is only available from the official github repository.
The standard approach is to add VRAME and Nine Auth Engine as git submodules:

    cd your_rails_app
    git submodule add git://github.com/sebastiandeutsch/vrame.git vendor/plugins/vrame
    git submodule add git://github.com/sebastiandeutsch/nine_auth_engine.git vendor/plugins/nine_auth_engine

There are plans to release VRAME as a gem when it has reachd a stable, more refined state.

Initialize VRAME 
----------------

    sudo rake gems:install
    rake vrame:bootstrap

Dependencies
------------

For those where rake gems:install does not work try adding these dependencies to your environment.rb

    config.gem 'coupa-acts_as_tree',
      :lib     => 'coupa-acts_as_tree',
      :source  => 'http://gems.github.com'
    
    config.gem 'binarylogic-authlogic',
      :lib     => 'authlogic',
      :source  => 'http://gems.github.com'
    
    config.gem 'mislav-will_paginate',
      :lib     => 'will_paginate',
      :source  => 'http://gems.github.com'
    
    config.gem 'mini_magick',
      :lib     => 'mini_magick'
    
    config.gem 'thoughtbot-paperclip',
      :lib     => 'paperclip',
      :source  => 'http://gems.github.com',
      :version => '~>2.3.1'
    
    config.gem 'norman-friendly_id',
      :lib     => 'friendly_id',
      :source  => 'http://gems.github.com'
    
    config.gem 'daemons'

Copyright (c) 2009 9elements.com, released under the MIT license
