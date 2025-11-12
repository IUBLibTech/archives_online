class IndexRepoJob
  include Sidekiq::Job

  def perform(args = {})
    EadProcessor.import_eads(args)
  end
end
