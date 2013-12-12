class RenameQuoteQuoteToText < ActiveRecord::Migration
  def change
    rename_column :quotes, :quote, :text
  end
end
