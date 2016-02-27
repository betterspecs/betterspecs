require 'i18n'

module Jekyll
  module Translate
    I18n.load_path += Dir['_i18n/*.yml']

    def translate(key)
      I18n.locale = @context.registers[:page]['locale'].intern
      I18n.t(key)
    end
  end
end

Liquid::Template.register_filter(Jekyll::Translate)
