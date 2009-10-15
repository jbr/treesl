require 'rubygems'
require 'active_support'

class TreeSL
  attr_accessor :matchers, :root_node, :post_procs, :namespace
  def initialize
    @matchers = {}
    @post_procs = {}
    @namespace = TreeSL
  end
  
  def self.define(namespace = nil, options = {}, &blk)
    rdp = TreeSL.new
    rdp.root_node = options[:root] || 'root'
    rdp.namespace = namespace if namespace
    rdp.instance_eval &blk
    rdp
  end
    
  def match(string, matcher = nil)
    matcher ||= root_node
    string.strip!
    # p [string,matcher]
    result = if matcher.is_a? Array
      matcher.each do |alternative|
        dup_string = string.dup
        if alternative_match = match(dup_string, alternative)
          string.replace dup_string
          return {alternative => alternative_match} 
        end
      end
      nil
    elsif matcher.is_a? String
      if matcher =~ / /
        matches = matcher.split(' ').inject({}) do |hash, atom|
          hash.merge atom => match(string, atom)
        end
        matches.values.any?{|v| v.nil?} ? nil : matches
      elsif new_matcher = matchers[matcher.to_sym]
        match string, new_matcher
      else
        match string, Regexp.new("^#{matcher}")
      end
    elsif matcher.is_a? Regexp
      if string =~ matcher
        string.gsub!(matcher, '');
        $&
      end
    end
    
    if result && matcher.is_a?(String) && matcher =~ /^[a-z_]+$/ && namespace.const_defined?(matcher.camelcase.to_sym)
      "#{namespace}::#{matcher.to_s.camelcase}".constantize.new(result) rescue result
    else
      result
    end
  end
  
  def rule(key, *values)
    key = key.to_sym
    matchers[key] = if matchers[key].nil?
      if values.length == 1
        values.first
      else
        values
      end
    else
      [matchers[key]].flatten + values
    end
  end
  
  def method_missing(method, *args)
    rule method, *args
  end
end
