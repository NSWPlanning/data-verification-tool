class RenameLgaRecordTransactionToTransactionType < ActiveRecord::Migration
  def change
    rename_column :local_government_area_records, :transaction, :transaction_type
  end
end
