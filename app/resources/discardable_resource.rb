class DiscardableResource < ApplicationResource
  abstract
  def remove
    run_callbacks :remove do
      :completed if @model.discard
    end
  end
end
