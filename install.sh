#!/bin/sh

tt lib/leirigrammar.treetop
rake clobber_package
rake gem
gem install pkg/*.gem
