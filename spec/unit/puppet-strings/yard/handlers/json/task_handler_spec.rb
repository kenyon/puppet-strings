# frozen_string_literal: true

require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::JSON::TaskHandler do
  subject(:spec_subject) do
    YARD::Parser::SourceParser.parse_string(source, :json)
    YARD::Registry.all(:puppet_task)
  end

  describe 'parsing task metadata with a syntax error' do
    let(:source) do
      <<-SOURCE
{
  "input_method": "stdin",
  "parameters":
    "database": {
      "description": "Database to connect to",
      "type": "Optional[String[1]]"
    }
  }
}
    SOURCE
    end

    it 'logs an error' do
      expect { spec_subject }.to output(%r{\[error\]: Failed to parse \(stdin\):}).to_stdout_from_any_process
      expect(spec_subject.empty?).to eq(true)
    end
  end

  describe 'parsing task metadata with a missing description' do
    let(:source) do
      <<-SOURCE
{
  "input_method": "stdin",
  "parameters": {
    "database": {
      "description": "Database to connect to",
      "type": "Optional[String[1]]"
    },
    "user": {
      "description": "The user",
      "type": "Optional[String[1]]"
    },
    "password": {
      "description": "The password",
      "type": "Optional[String[1]]"
    },
     "sql": {
      "description": "Path to file you want backup to",
      "type": "String[1]"
    }
  }
}
    SOURCE
    end

    it 'logs a warning' do
      expect { spec_subject }.to output(%r{\[warn\]: Missing a description for Puppet Task \(stdin\)}).to_stdout_from_any_process
    end
  end

  describe 'parsing task metadata with a description' do
    let(:source) do
      <<-SOURCE
{
  "description": "Allows you to backup your database to local file.",
  "input_method": "stdin",
  "parameters": {
    "database": {
      "description": "Database to connect to",
      "type": "Optional[String[1]]"
    },
    "user": {
      "description": "The user",
      "type": "Optional[String[1]]"
    },
    "password": {
      "description": "The password",
      "type": "Optional[String[1]]"
    },
     "sql": {
      "description": "Path to file you want backup to",
      "type": "String[1]"
    }
  }
}

    SOURCE
    end

    it 'registers a task object' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::Task)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::Tasks.instance)
    end
  end

  describe 'parsing task metadata with a missing parameter description' do
    let(:source) do
      <<-SOURCE
{
  "description": "Allows you to backup your database to local file.",
  "input_method": "stdin",
  "parameters": {
    "database": {
      "type": "Optional[String[1]]"
    }
  }
}
    SOURCE
    end

    it 'outputs a warning' do
      expect { spec_subject }.to output(%r{\[warn\]: Missing description for param 'database' in Puppet Task \(stdin\)}).to_stdout_from_any_process
    end
  end
end
