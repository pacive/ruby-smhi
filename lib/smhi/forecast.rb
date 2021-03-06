# forecast.rb
# frozen_string_literal: true

module SMHI
  ##
  # A class for convenient access to a weather forecast from SMHI
  #
  # SMHI::Forecast offers many ways to get the data one needs by providing several
  # aliases and allows chaining of methods to narrow down the search.
  #
  # ==Example:
  #
  #   require 'smhi'
  #
  #   fcst = SMHI.parse(SMHI.point_forecast(57.999628, 16.017767))
  #   fcst.temperature.at(Time.now) # => Float
  #   fcst.precip_mean.between((Time.now + 2 * 3600)..(Time.now + 5 * 3600)).values # => Array
  #   fcst.wd[2] # => Integer
  #   fcst['visibility'][0] # => Float
  #
  # For more information on the available parameters,
  # see http://opendata.smhi.se/apidocs/metfcst/parameters.html#parameter-table
  class Forecast
    include Enumerable

    attr_reader :forecast, :reference_time, :lat, :lon

    PARAMETERS = %i[msl t vis wd ws r tstm tcc_mean
                    lcc_mean mcc_mean hcc_mean gust pmin pmax
                    spp pcat pmean pmedian Wsymb2].freeze
    PARAMETER_ALIASES = { pressure: :msl,
                          temperature: :t,
                          visibility: :vis,
                          wind_direction: :wd,
                          wind_speed: :ws,
                          relative_humidity: :r,
                          humidity: :r,
                          thunder_probability: :tstm,
                          total_cloud_cover: :tcc_mean,
                          low_cloud_cover: :lcc_mean,
                          medium_cloud_cover: :mcc_mean,
                          high_cloud_cover: :hcc_mean,
                          wind_gust: :gust,
                          precipitation_min: :pmin,
                          precip_min: :pmin,
                          precipitation_max: :pmax,
                          precip_max: :pmax,
                          percent_frozen_precipitation: :spp,
                          frozen_precip: :spp,
                          precipitation_category: :pcat,
                          precip_cat: :pcat,
                          precipitation_mean: :pmean,
                          precip_mean: :pmean,
                          precipitation_median: :pmedian,
                          precip_median: :pmedian,
                          weather_symbol: :Wsymb2,
                          symbol: :Wsymb2 }.freeze

    ##
    # Do not use +::new+ to instantiate a new forecast,
    # use +SMHI::parse+ instead
    def initialize(forecast, reference_time, lat, lon)
      @reference_time = reference_time
      @lat = lat
      @lon = lon
      if forecast.is_a?(Hash) && forecast.keys.first.is_a?(Time)
        @forecast = []
        forecast.each do |k, v|
          @forecast << TimeForecast.new(k, v)
        end
      elsif forecast.is_a?(Array) && forecast.first.is_a?(TimeForecast)
        @forecast = forecast
      else
        raise ArgumentError, 'Illegal argument'
      end
    end

    ##
    # call-seq:
    #  each { |time_forecast| block } => fcst
    #  each => an_enumerator
    #
    # Calls block for each forecast, passing the timestamp and forecast as parameters
    # If no block is given, returns an Enumerator object instad
    def each(&block)
      @forecast.each(&block)
    end

    ##
    # call-seq:
    #  Forecast[ integer ] => Hash or Numeric
    #  Forecast[ time ] => Hash or Numeric
    #  Forecast[ symbol ] => Forecast
    #  Forecast[ string ] => Forecast
    #
    # If a +Integer n+ is passed, returns the n-th (zero-based) forecast.
    # If a +Time+ object is passed, returns the forecast for the specified time.
    # If the forecast is already narrowed down to contain a single parameter,
    # returns the value for that parameter, otherwise returns a Hash containing
    # all parameters.
    #
    # If a +Symbol+ or a +String+ with a parameter name or alias is passed, returns
    # a Forecast object containing only that parameter.
    def [](value)
      case value
      when Integer then @forecast[value]
      when Time then at(value)
      when Symbol then send(value)
      when String then send(value.to_sym)
      end
    end

    ##
    # call-seq:
    #  at(time) => Hash or Numeric
    #
    # Returns the forecast for the specified +time+.
    # If the forecast is already narrowed down to contain a single parameter,
    # returns the value for that parameter, otherwise returns a Hash containing
    # all parameters.
    def at(time)
      tfcst = @forecast.bsearch { |tf| tf.time >= time }
      tfcst.parameters
    end

    ##
    # call-seq:
    #  between(range) => Forecast
    #  between(start, end) => Forecast
    #
    # Returns a Forecast object containing forecasts that lies within +range+ or
    # between +start+ and +end+.
    def between(*args)
      range = case args[0]
              when Range then args[0]
              when Time then args[0]..args[1]
              else raise ArgumentError
              end

      f = @forecast.select { |tf| range.cover? tf.time }
      Forecast.new(f, @reference_time, @lat, @lon)
    end

    ##
    # call-seq:
    #  until(time) => Forecast
    #  before(time) => Forecast
    #
    # Returns a Forecast object containing forecasts that lies before +time+.
    def until(time)
      f = @forecast.select { |tf| tf.time < time }
      Forecast.new(f, @reference_time, @lat, @lon)
    end

    alias before until

    # Returns a Forecast object containing forecasts that lies after +time+.
    def after(time)
      f = @forecast.select { |tf| tf.time > time }
      Forecast.new(f, @reference_time, @lat, @lon)
    end

    ##
    # call-seq:
    #  inspect => String
    #  to_s => String
    #
    # Return a string representation of the Forecast object.
    def inspect
      @forecast.inspect
    end

    alias to_s inspect

    ##
    # call-seq:
    #  values => Array
    #  to_a => Array
    #
    # Return an array containing all forecast parameters.
    def values
      @forecast
    end

    alias to_a values

    def respond_to_missing?
      true
    end

    private

    def method_missing(sym, *args, &block)
      if PARAMETERS.include? sym
        select(sym)
      elsif PARAMETER_ALIASES.include? sym
        select(PARAMETER_ALIASES[sym])
      else
        super
      end
    end

    def select(parameter)
      hash = {}
      @forecast.each { |tf| hash[tf.time] = tf[parameter] }
      Forecast.new(hash, @reference_time, @lat, @lon)
    end
  end
end
