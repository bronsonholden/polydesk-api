class UpdatePathOnFolders < ActiveRecord::Migration[5.2]
  def up
    folders = Folder.all

    to_visit = folders.where(parent_id: 0).to_a
    queue = []
    while to_visit.present?
      current = to_visit.shift
      queue << current
      to_visit.concat(current.children)
    end

    queue.each { |folder|
      folder.update_path!
    }
  end
end
