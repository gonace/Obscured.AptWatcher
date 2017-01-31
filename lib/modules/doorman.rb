lib = File.dirname(__FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rack/contrib/cookies'
require File.expand_path('../doorman/domain/entity', __FILE__)
require File.expand_path('../doorman/domain/history', __FILE__)
require File.expand_path('../doorman/utils/titles', __FILE__)
require File.expand_path('../doorman/utils/roles', __FILE__)
require File.expand_path('../doorman/utils/types', __FILE__)
require File.expand_path('../doorman/messages', __FILE__)
require File.expand_path('../doorman/user', __FILE__)
require File.expand_path('../doorman/base', __FILE__)