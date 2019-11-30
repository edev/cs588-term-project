#!/usr/bin/env ruby

##
# This script answers project question 2:
#
# "Compare the sum of all sign-ups for TDB Need to those from last year
#  as of the same date."
#
# It takes two arguments: a need slug denoting the need to analyze
# and a cutoff date in the form YYYY-MM-DD. The given year will be compared to
# the previous year's data as of the same month and day (including sign-ups
# on the cutoff day). Untracked donations are not included, as they have no
# date data associated with them in the existing dataset.
#
# Example:
#
# ruby question2.rb choir_singers 2017-12-10

require 'cgi'
require 'date'
require 'json'
require 'net/http'
require_relative 'lib/couchdb'

##
# Retrieves the correct document for a given need in a particular year,
# then sums up the sign-ups on or before the given date.
#
# Returns the sum of the filtered sign-ups.
def get(need_slug, year, month, day)
    # Slashes in document IDs need to be URL-escaped.
    doc_id = CGI::escape "needs/#{need_slug}/#{year}"

    # Retrieve the need and parse it to a Hash.
    uri = URI::HTTP.build(
        host: CouchDB::HOSTNAME,
        port: CouchDB::PORT,
        path: "#{CouchDB::DB}/#{doc_id}"
    )
    need = JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
    
    cutoff = Date.new(year, month, day)
    need[:sign_ups].reduce(0) do |memo, su|
        d = Date.parse su[:created_at]
        if d <= cutoff
            memo + su[:quantity]
        else
            memo
        end
    end
end

# Parse command-line arguments.

if ARGV.length != 2
    STDERR.puts "Expected 2 arguments: need slug and cutoff date (YYYY-MM-DD)."
    exit(1)
end

$need_slug = ARGV[0]

# May raise an exception, which will be passed on to the user.
# No exception means date parsed successfully.
cutoff_date = Date.parse(ARGV[1])
$year = cutoff_date.year
$month = cutoff_date.month
$day = cutoff_date.day

# Retrieve our two years' sums.
this_year = get($need_slug, $year, $month, $day)
last_year = get($need_slug, $year-1, $month, $day)

# Print our findings.
puts <<~END
    Sign-ups for #{$need_slug} by #{$month}/#{$day}:
        - #{$year}: #{this_year} sign-ups
        - #{$year-1}: #{last_year} sign-ups
END
