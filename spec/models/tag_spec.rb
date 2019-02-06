# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  it_behaves_like "sluggable"
end
