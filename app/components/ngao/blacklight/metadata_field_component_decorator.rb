# frozen_string_literal: true

module Ngao
  module Blacklight
    module MetadataFieldComponentDecorator
      def label
        key = @field.key
        document = @field.document
        heading_field = "#{key}_heading_ssm"

        label = document[heading_field]&.first
        return super unless label

        "#{label}:"
      end
    end
  end
end

Blacklight::MetadataFieldComponent.prepend(Ngao::Blacklight::MetadataFieldComponentDecorator)
