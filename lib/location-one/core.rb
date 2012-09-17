require 'geocoder'
require 'json'
require 'httpclient'

module LocationOne
  #SUPPORTED_BACKENDS =
  #    {
  #        :calabashios => {:path => "/uia"},
  #        :calabashandroid => {:path => "/uia"},
  #        :frank => {:path => "/tbd"},
  #
  #    }

  class Client
    attr_accessor :http, :backend

    def initialize(backend, opt_client=nil)
      @backend = backend
      @http = opt_client
    end

    def change_location(options, opt_data={})
      if (options[:latitude] and not options[:longitude]) or
          (options[:longitude] and not options[:latitude])
        raise "Both latitude and longitude must be specified if either is."
      end
      if (options[:latitude])
        change_location_by_coords(options[:latitude], options[:longitude], opt_data)
      else
        if not options[:place]
          raise "Either :place or :latitude and :longitude must be specified."
        end
        change_location_by_place(options[:place], opt_data)
      end
    end

    def change_location_by_coords(lat, lon, opt_data={})

      body_data = {:action => :change_location,
                   :latitude => lat,
                   :longitude => lon}.merge(opt_data)



      body = make_http_request(
          :uri => URI.parse("http://#{@backend[:host]}:#{@backend[:port]}#{@backend[:path]}"),
          :method => :post,
          :body => body_data.to_json
      )


      unless body
        raise "Set location change failed, for #{lat}, #{lon} (#{body})."
      end
      body
    end

    def self.location_by_place(place)
      results = Geocoder.search(place)
      raise "Got no results for #{place}" if results.empty?
      results.first
    end

    def change_location_by_place(place, opt_data={})
      best_result = Client.location_by_place(place)
      change_location_by_coords(best_result.latitude, best_result.longitude, opt_data)
    end

    def make_http_request(options)
      body = nil
      3.times do |count|
        begin
          if not @http
            @http = init_request(options)
          end
          if options[:method] == :post
            body = @http.post(options[:uri], options[:body]).body
          else
            body = @http.get(options[:uri], options[:body]).body
          end
          break
        rescue HTTPClient::TimeoutError => e
          if count < 2
            sleep(0.5)
            @http.reset_all
            @http=nil
            STDOUT.write "Retrying.. #{e.class}: (#{e})\n"
            STDOUT.flush

          else
            puts "Failing... #{e.class}"
            raise e
          end
        rescue Exception => e
          case e
            when Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ECONNABORTED, Errno::ETIMEDOUT
              if count < 2
                sleep(0.5)
                @http.reset_all
                @http=nil
                STDOUT.write "Retrying.. #{e.class}: (#{e})\n"
                STDOUT.flush

              else
                puts "Failing... #{e.class}"
                raise e
              end
            else
              raise e
          end
        end
      end

      body
    end

    def init_request(url)
      http = HTTPClient.new
      http.connect_timeout = 15
      http.send_timeout = 15
      http.receive_timeout = 15
      http
    end

  end
end
