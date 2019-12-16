# time_forecast.rb
# frozen_string_literal: true

module SMHI
  #
  # Internal class for the forecast at a specific time.
  class TimeForecast
    include Comparable

    attr_reader :time, :parameters

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
                          symbol: :Wsymb2,
                          wsymb: :Wsymb2 }.freeze

    PARAMETERS.each do |p|
      define_method(p) { @parameters[p] }
    end

    PARAMETER_ALIASES.each do |k, v|
      alias_method k, v
    end

    def initialize(time, parameters)
      @time = time
      @parameters = parameters
    end

    def [](value)
      send(value)
    end

    def <=>(other)
      @time <=> other.time
    end
  end
end
