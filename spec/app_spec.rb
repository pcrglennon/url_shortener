require 'spec_helper'

RSpec.describe(UrlShortener::App) do
  def app
    described_class
  end

  describe 'GET "/"' do
    before { get '/' }

    it 'should return a 200' do
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET "/:key"' do
    let(:key) { '186a0' }

    context 'with a key in the DB' do
      before do
        allow(REDIS).to receive(:get).with(key) { 'https://example.org/some/neato/thing' }

        get "/#{key}"
      end

      it 'should redirect to the URL corresponding to the key' do
        expect(last_response).to be_redirect

        follow_redirect!
        expect(last_request.url).to eq('https://example.org/some/neato/thing')
      end
    end

    context 'with a key not in the DB' do
      before { get "/#{key}" }

      it 'should render the index page and display an error' do
        expect(last_response.body).to include("Could not find a link for key #{key}")
      end
    end
  end

  describe 'POST "/"' do
    context 'with a properly-formatted URL' do
      let(:url) { 'https://example.org/some/neato/thing' }

      before do
        allow(REDIS).to receive(:incr).with('count') { 100000 }
        allow(REDIS).to receive(:mset)

        post '/', { url: url }
      end

      it 'should increment the total count of key-value pairs' do
        expect(REDIS).to have_received(:incr).with('count')
      end

      it 'should insert the URL with a key of the next-available hex value' do
        expect(REDIS).to have_received(:mset).with('186a0', url)
      end

      it 'should render the index page and display the shortened URL' do
        expected_short_url = "#{last_request.base_url}/186a0"

        expect(last_response.body).to match(/<a href="#{expected_short_url}">#{expected_short_url}<\/a>/)
      end
    end

    context 'with an improperly-formatted URL' do
      let(:url) { 'this is not a URL' }

      before do
        allow(REDIS).to receive(:incr)
        allow(REDIS).to receive(:mset)

        post '/', { url: url }
      end

      it 'should not increment the total count of key-value pairs' do
        expect(REDIS).to_not have_received(:incr)
      end

      it 'should not insert anything into the DB' do
        expect(REDIS).to_not have_received(:mset)
      end

      it 'should render the index page and display an error' do
        expect(last_response.body).to include("Invalid URL: \"#{url}\"")
      end
    end
  end
end
