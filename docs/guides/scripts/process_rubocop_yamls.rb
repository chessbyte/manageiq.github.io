#!/usr/bin/env ruby

require 'rubocop'
require 'yaml'
require 'active_support/core_ext/class'
require 'active_support/core_ext/string'

module Shared
  TARGET_RUBY_VERSION = 2.4

  def self.cops_and_departments
    cops = RuboCop::Cop::Cop.subclasses.map { |c| c.name.split("::").last(2).join("/") }.sort
    departments = cops.map { |c| c.split("/").first }.uniq
    [cops, departments]
  end
end

module YamlBuilder
  FILE = File.expand_path("../.rubocop_base.yml", __dir__)

  def self.check
    cops, departments = Shared.cops_and_departments

    issues = []

    base = YAML.load_file(FILE)
    if base.delete("AllCops") != {"TargetRubyVersion" => Shared::TARGET_RUBY_VERSION}
      issues << "AllCops -> TargetRubyVersion should be #{Shared::TARGET_RUBY_VERSION}"
    end

    base.keys.each do |base_cop|
      if base_cop.include?("/")
        unless cops.include?(base_cop)
          issue = "#{base_cop.inspect} is an invalid cop name."

          base_cop_name = "/#{base_cop.split("/").last}"
          could_be = cops.select { |cop| cop.end_with?(base_cop_name) }
          issue << " Did you mean #{could_be.map(&:inspect).join(", ")}?" if could_be.any?

          issues << issue
        end
      else
        unless departments.include?(base_cop)
          issues << "#{base_cop.inspect} is an invalid department name."
        end
      end
    end

    if issues.any?
      puts "Issues found in #{FILE}:"
      puts issues.map { |i| i.indent(2) }
    end
  end
end

module CCYamlBuilder
  FILE = File.expand_path("../.rubocop_cc_base.yml", __dir__)

  def self.build
    cops, departments = Shared.cops_and_departments

    result = {"AllCops" => {"TargetRubyVersion" => Shared::TARGET_RUBY_VERSION}}

    (departments - ["Metrics"]).each do |d|
      result[d] = determine_department_rules(d)
    end

    metrics_cops = cops.select { |c| c.start_with?("Metrics/") }
    metrics_cops.each do |c|
      result[c] = determine_metrics_rules(c)
    end

    output = <<-EOF
#
# THIS FILE IS AUTOGENERATED. DO NOT MODIFY MANUALLY.
# For changes, please modify #{__FILE__}
#
#{result.to_yaml}
    EOF
    File.write(FILE, output)
  end

  private_class_method def self.determine_department_rules(department)
    {
      "Enabled" =>
        case department
        when "Bundler", "Gemspec", "Lint", "Performance", "Security"
          true
        when "Layout", "Naming", "Rails", "Style"
          false
        when "Metrics"
          raise "You should not be here because these are handled specially"
        else
          raise "Unknown department: #{deparment}"
        end
    }
  end

  private_class_method def self.determine_metrics_rules(cop)
    result = {
      "Enabled" =>
        %w(
          Metrics/BlockNesting
          Metrics/CyclomaticComplexity
          Metrics/ParameterLists
        ).include?(cop)
    }
    result["Max"] = 11 if cop == "Metrics/CyclomaticComplexity"

    result
  end
end

puts "Processing .rubocop yaml files with RuboCop #{RuboCop::Version::STRING}"
YamlBuilder.check
CCYamlBuilder.build