class IndexFileJob
  include Sidekiq::Job

  def perform(filename, repository)
    ENV['REPOSITORY_ID'] = repository
    ENV['FILE'] = filename
    system('bundle exec rake arclight:index', exception: true)
  end
end
