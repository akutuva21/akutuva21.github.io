require_relative 'spec_helper'
require_relative '../_plugins/inspirehep-citations'

describe Jekyll::InspireHEPCitationsTag do
  let(:tag_name) { 'inspirehep_citations' }
  let(:params) { 'recid' }
  let(:tokens) { Liquid::ParseContext.new }
  let(:context) { Liquid::Context.new({'recid' => '12345'}) }

  before do
    Jekyll::InspireHEPCitationsTag::Citations.clear
  end

  it 'returns "N/A" on API failure' do
    # Mocking Net::HTTP.get to raise an error
    Net::HTTP.stub :get, ->(uri) { raise StandardError.new("API Error") } do
      tag = Liquid::Template.tags['inspirehep_citations'].send(:new, tag_name, params, tokens)

      # Capture standard output since code does `puts`
      output = capture_io do
        result = tag.render(context)
        _(result).must_equal "N/A"
      end

      _(output[0]).must_include "Error fetching citation count for 12345: StandardError - API Error"
      _(Jekyll::InspireHEPCitationsTag::Citations['12345']).must_equal "N/A"
    end
  end

  it 'successfully fetches and formats citation count' do
    valid_json = {
      "hits" => {
        "hits" => [
          { "metadata" => { "citation_count" => 1500 } }
        ]
      }
    }.to_json

    Net::HTTP.stub :get, valid_json do
      tag = Liquid::Template.tags['inspirehep_citations'].send(:new, tag_name, params, tokens)
      result = tag.render(context)
      _(result).must_equal "1.5K" # Actual active_support format
    end
  end
end
