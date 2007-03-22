# Copyright (c) 2006 Surendra K. Singhi <ssinghi@kreeti.com>

#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

ActiveRecord::Schema.define(:version => 0) do
  create_table :comments, :force => true do |t|
    t.column :title, :string
    t.column :body,  :string
  end
  create_table :classifier_models, :force => true do |t|
      t.column :identifier, :int
      t.column :classifiable_type, :string, :null => false
      t.column :data, :blob
  end
  add_index :classifier_models, [:classifiable_type, :identifier], :name => "classifiable_models_index_identifier_type"
end
