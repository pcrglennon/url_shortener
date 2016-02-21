require 'spec_helper'

RSpec.describe(UrlShortener::App) do
  def app
    described_class
  end

  let(:redis) { UrlShortener::App::REDIS }

  describe 'GET "/"' do
    let(:shortlinks) { ['foo', 'bar', 'a', 'b'] }

    before do
      # Seed Redis w/ the shortlinks (with increasing # of hits)
      shortlinks.each_with_index do |shortlink, i|
        redis.mset(shortlink, "https://example.org/#{shortlink}")
        redis.zadd('hits', (i + 1), shortlink)
      end

      get '/'
    end

    it 'should return a 200' do
      expect(last_response.status).to eq(200)
    end

    it 'should render the index page' do
      expect(last_response.body).to include('Url Shortener App')
    end
  end

  describe 'GET "/:key"' do
    let(:key) { '186a0' }

    context 'with a key in the DB' do
      before do
        redis.zadd('hits', 1, key)

        allow(redis).to receive(:get).with(key) { 'https://example.org/some/neato/thing' }
        allow(redis).to receive(:zincrby)

        get "/#{key}"
      end

      it 'should redirect to the URL corresponding to the key' do
        expect(last_response).to be_redirect

        follow_redirect!
        expect(last_request.url).to eq('https://example.org/some/neato/thing')
      end

      it 'should increment the hits counter for that key' do
        expect(redis).to have_received(:zincrby).with('hits', 1, key)
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
        allow(redis).to receive(:incr).with('count') { 100000 }
        allow(redis).to receive(:mset)

        post '/', { url: url }
      end

      it 'should increment the total count of key-value pairs' do
        expect(redis).to have_received(:incr).with('count')
      end

      it 'should insert the URL with a key of the next-available hex value' do
        expect(redis).to have_received(:mset).with('186a0', url)
      end

      it 'should return a 201' do
        expect(last_response.status).to eq(201)
      end

      it 'should return the shortlink key' do
        expect(last_response.body).to eq({ key: '186a0' }.to_json);
      end
    end

    context 'with an improperly-formatted URL' do
      let(:url) { 'this is not a URL' }

      before do
        allow(redis).to receive(:incr)
        allow(redis).to receive(:mset)

        post '/', { url: url }
      end

      it 'should not increment the total count of key-value pairs' do
        expect(redis).to_not have_received(:incr)
      end

      it 'should not insert anything into the DB' do
        expect(redis).to_not have_received(:mset)
      end

      it 'should return a 400' do
        expect(last_response.status).to eq(400)
      end

      it 'should return the shortlink key' do
        expect(last_response.body).to eq({ message: "Invalid URL: \"#{url}\"" }.to_json);
      end
    end
  end
end
