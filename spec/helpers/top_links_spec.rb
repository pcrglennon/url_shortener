require 'spec_helper'

RSpec.describe(UrlShortener::TopLinks) do
  def app
    UrlShortener::App
  end

  let(:top_links) { described_class.new }

  let(:top_5) do
    5.downto(1).map do |i|
      { :hits => i, :key => "#{i}", :destination => "http://example.com/#{i}" }
    end
  end

  describe '#links' do
    context 'with links with hit counts' do
      before do
        top_5.each do |link|
          REDIS.set(link[:key], link[:destination])
          REDIS.zadd(described_class::HITS, link[:hits], link[:key])
        end
      end

      context 'with a cached list of top N links' do
        before do
          REDIS.set('_top_5', { links: top_5 }.to_json)
        end

        it 'should return the cached list' do
          expect(top_links.links(5)).to eq(top_5)
        end

        context 'when the real top N links have changed' do
          before do
            REDIS.zincrby(described_class::HITS, 2, '1')
            allow(REDIS).to receive(:zrevrange)
          end

          it 'should return the cached list' do
            expect(top_links.links(5)).to eq(top_5)
          end

          it 'should not calculate a a new ranked list' do
            top_links.links(5)

            expect(REDIS).to_not have_received(:zrevrange)
          end
        end
      end

      context 'without a cached list of the top N links' do
        before do
          allow(REDIS).to receive(:set)
          allow(REDIS).to receive(:expire)
        end

        it 'should cache that list' do
          top_links.links(5)

          expect(REDIS).to have_received(:set).with('_top_5', { links: top_5 }.to_json)
        end

        it 'should expire the cached list after 10 minutes' do
          top_links.links(5)

          expect(REDIS).to have_received(:expire).with('_top_5', 600)
        end

        it 'should return that list' do
          expect(top_links.links(5)).to eq(top_5)
        end
      end
    end

    context 'without any links with hit counts' do
      it 'should return an empty list' do
        expect(top_links.links(5)).to eq([])
      end
    end
  end

  describe '#increment' do
    context 'with a shortlink with a hit count' do
      before do
        REDIS.zadd(described_class::HITS, 1, '1')
      end

      it 'should increment that shortlink\'s hit count by 1' do
        top_links.increment('1')

        expect(REDIS.zscore(described_class::HITS, '1')).to eq(2)
      end
    end

    context 'with a shortlink without a hit count' do
      it 'should set that shortlink\'s hit count to 1' do
        top_links.increment('1')

        expect(REDIS.zscore(described_class::HITS, '1')).to eq(1)
      end
    end
  end
end
