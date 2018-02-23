# smhi.rb
# frozen_string_literal: true

require 'net/http'
require 'time'
require_relative 'smhi/forecast'

##
# A flexible gem for getting weather forecasts from SMHI
# 
module SMHI
  VERSION = '0.1.0'
  BASE_URI = 'https://opendata-download-metfcst.smhi.se'
  API_ENDPOINT = '/api/category/pmp3g/version/2'

  # call-seq:
  #  approved_time => String
  #
  # Get the time of the latest approved forecast.
  def self.approved_time
    uri = URI(BASE_URI + API_ENDPOINT + '/approvedtime.json')

    Net::HTTP.get(uri)
  end

  # call-seq:
  #  point_forecast(latitude, longitude) => String
  #
  # Get forecast for the specified location.
  def self.point_forecast(latitude, longitude)
    uri = URI(BASE_URI + API_ENDPOINT + "/geotype/point/lon/#{longitude}/lat/#{latitude}/data.json")

    Net::HTTP.get(uri)
  end

  # call-seq:
  #  parse(json) => Forecast
  #
  # Parse a json string retrieved using +SMHI.point_forecast+ and converts to a +SMHI::Forecast+ object.
  def self.parse(json)
    fcst = {}
    data = JSON.parse(json)
    data['timeSeries'].each do |h|
      parameters = {}
      h['parameters'].each do |par|
        parameters[par['name'].to_sym] = par['values'][0]
      end
      fcst[Time.parse(h['validTime'])] = parameters
    end
    Forecast.new(fcst, Time.parse(data['referenceTime']), data['geometry']['coordinates'][1], data['geometry']['coordinates'][0])
  end
end