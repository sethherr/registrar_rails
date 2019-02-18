# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  it_behaves_like "sluggable"

  describe "child and parent tags" do
    let(:tag_parent) { FactoryBot.create(:tag) }
    let(:tag_child1) { FactoryBot.create(:tag, parent_id: tag_parent.id) }
    let(:tag_child2) { FactoryBot.create(:tag, parent_id: tag_parent.id) }
    let(:tag_grandchild) { FactoryBot.create(:tag, parent_id: tag_child2.id) }
    let(:tag_great_grandchild) { FactoryBot.build(:tag, parent_id: tag_grandchild.id) }
    it "returns correct association" do
      expect do
        [tag_child1, tag_child2, tag_grandchild, tag_great_grandchild].each { |t| expect(t).to be_present }
      end.to change(Tag, :count).by 4 # We just want these tags
      expect(tag_child1.parent_tags).to eq([tag_parent])
      expect(tag_parent.child_tags.pluck(:id)).to match_array([tag_child1.id, tag_child2.id, tag_grandchild.id])
      expect(tag_grandchild.parent_tags.pluck(:id)).to match_array([tag_parent.id, tag_child2.id])
      expect { tag_great_grandchild.save }.to raise_error(/great grandchild/i) # Simple hacky fix for now
    end
  end
end
