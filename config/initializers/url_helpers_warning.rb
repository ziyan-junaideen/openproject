module CLI
  module Colors
    def self.[](key)
      case key
      when :blue
        34
      when :yellow
        33
      when :green
        32
      when :red
        31
      else
        37 # light  gray
      end
    end

    def self.color_string(color_code, string)
      "\e[#{color_code}m#{string}\e[0m"
    end
  end
end

class String
  def painted(color)
    CLI::Colors.color_string(CLI::Colors[color], self)
  end
end

module Betterment
  def self.check_call_site
    callers = caller
    if callers.any? { |cal| cal.include?("/models/") || cal.include?("/openproject/lib/") }
      site = callers.find do |cal|
        if !(cal =~ /url_helpers_warning.rb/)
          cal = cal.gsub(/^.*:\d+:/, "")
          (cal =~ /(\(required\))|(include)/)
        end
      end
      unless site =~ /\/static_routing\.rb.*/ || site.nil? || sites.any? { |s| site =~ /#{s}/ }
        site = site.gsub(/:.*$/, "")
        warning = <<-WARN

          You are using URL helpers outside the view or controller context.
          This will produce broken links in that host and subdirectory within
          the link will not be correct. The offending file is:
          #{"  " + site}

          You may want to use OpenProject::StaticRouting::UrlHelpers.
        WARN

        puts warning.split("\n").map(&:strip).join("\n[warning] ").painted(:yellow)
        sites << site
      end
    end
  end

  def self.sites
    @sites ||= []
  end
end

if Rails.env.development?
  ActionDispatch::Routing::RouteSet.class_eval do
    def url_helpers_with_warning
      Betterment.check_call_site
      url_helpers_without_warning
    end

    alias_method_chain :url_helpers, :warning
  end

  ActionView::Helpers::UrlHelper.module_eval do
    included do
      Betterment.check_call_site
    end
  end
end
