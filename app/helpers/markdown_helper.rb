# frozen_string_literal: true

require "kramdown"

module MarkdownHelper
  def markdown_to_html(markdown)
    Kramdown::Document.new(markdown).to_html
  end
end
