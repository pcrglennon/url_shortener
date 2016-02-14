require 'spec_helper'

RSpec.describe(UrlShortener::App) do
  def app
    described_class
  end

  # let(:redis) { object_double('REDIS').as_stubbed_const }

  describe 'GET "/"' do
    before { get '/' }

    it 'should return a 200' do
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST "/"' do
    context 'with a properly-formatted URL' do
      let(:url) { 'https://example.com/some/neato/thing' }

      before do
        allow(REDIS).to receive(:incr).with('count') { 100000 }
        allow(REDIS).to receive(:mset)
        post '/', { url: url }
      end

      it 'should return a 201' do
        expect(last_response.status).to eq(201)
      end

      it 'should increment to total count of key-value pairs' do
        expect(REDIS).to have_received(:incr).with('count')
      end

      it 'should insert the URL with a key of the next-available hex value' do
        expect(REDIS).to have_received(:mset).with('186a0', url)
      end
    end
  end

  context 'with an improperly-formatted URL' do
    let(:url) { 'this is not a URL' }

    before { post '/', { url: url } }
  end
end
