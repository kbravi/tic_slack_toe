class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ArrayHelper

  include Slacker::ResponsePackager
end
