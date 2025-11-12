class IndexSingleEadJob
  include Sidekiq::Job

  def perform(args = {})
    EadProcessor.index_single_ead(args)
  end
end
