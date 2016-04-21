
require 'json'
require 'rest-client'
require 'net/smtp'

def shasm
  send_email
end

def get_movies(min_score=90, availability="in-theaters", certified="true", genres="10")

  # creates a URL for the rotten tomatoes private API
  base_url = "https://d3biamo577v4eu.cloudfront.net/api/private/v1.0/m/list/find?page=1&limit=30&type=#{availability}&minTomato=#{min_score}&genres=#{genres}&certified=#{certified}&sortBy=release"
  print base_url
  #load results JSON
  data = JSON.load(RestClient.get(base_url))
  new_movies = []

  #fetches list of movies already seen from local file

  #TODO figure out how to pass in a users local pathway, config file?
  log_file = open("/Users/kari_tarr/Dropbox/code/life_hacking/movies_seen.txt", "r")
  movies_seen = log_file.read

  #append only new movies to local file
  for m in data['results']
    unless movies_seen.include?(m['title'] + "\n")
      log_file = open("/Users/kari_tarr/Dropbox/code/life_hacking/movies_seen.txt", "a") { |f|
          f << m['title'] + "\n"
      }
      new_movies.push(
        "title: " + m['title'].to_s.force_encoding("iso-8859-1") +
        "\nrating: " + m['tomatoScore'].to_s +
        "\nsynopsis: " + m['synopsis'].force_encoding("iso-8859-1").to_s +
        "\nurl: https://rottentomatoes.com" + m['url'].force_encoding("iso-8859-1").to_s +
        "\ntheater release date: " + m['theaterReleaseDate'].to_s.force_encoding("iso-8859-1") +
        "\ndvd release date: " + m['dvdReleaseDate'].to_s.force_encoding("iso-8859-1")
      )
    end
  end
  return new_movies
end

def send_email
  #TODO only send if array is > 1
  all_movies = get_movies(70, "in-theaters", certified="true") + all_movies = get_movies(70, "dvd-all", certified="true")
  msg = "Subject: ShasMaster Says...\n\nHere's the latest horror movies you need to see: \n\n" + all_movies.join("\n\n***\n\n")
  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  # TODO encrypt password (https://github.com/fcheung/keychain or use a config file)
     smtp.start('gmail.com', 'karitarr', 'lucca1234', :login) do
        smtp.send_message(msg, 'karitarr@gmail.com', ['kari.tarr@airbnb.com', 'herman.yu@airbnb.com', 'karitarr@gmail.com', 'manuel@summer.ai'])
    end
end

shasm


