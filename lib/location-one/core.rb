require 'geocoder'
require 'json'
require 'net/http'

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

    def initialize(backend,opt_client=nil)
      @backend = backend
      @http = opt_client || Net::HTTP.new(backend[:host], backend[:port])
    end

    def change_location(options, opt_data={})

      if (options[:latitude] and not options[:longitude]) or
          (options[:longitude] and not options[:latitude])
        raise "Both latitude and longitude must be specified if either is."
      end
      if (options[:latitude])
        change_location_by_coords(options[:latitude], options[:longitude],opt_data)
      else
        if not options[:place]
          raise "Either :place or :latitude and :longitude must be specified."
        end
        change_location_by_place(options[:place],opt_data)
      end
    end

    def change_location_by_coords(lat, lon,opt_data={})
      req = Net::HTTP::Post.new(backend[:path])

      body_data = {:action => :change_location,
                   :latitude => lat,
                   :longitude => lon}.merge(opt_data)

      req.body = body_data.to_json

      res = @http.request(req)

      begin
        @http.finish if @http.started?
      rescue

      end
      if res.code !='200'
        raise "Response error code #{res.code}, for #{lat}, #{lon} (#{res.body})."
      end
      res.body
    end

    def change_location_by_place(place,opt_data={})
      results = Geocoder.search(place)
      raise "Got no results for #{place}" if results.empty?
      best_result = results.first
      change_location_by_coords(best_result.latitude, best_result.longitude,opt_data)
    end

  end
end
