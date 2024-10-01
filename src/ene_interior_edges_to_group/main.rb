module Eneroth
  # Eneroth Interior Edges to Groups
  module InteriorEdgesToGroup
    unless @loaded
      @loaded = true

      menu = UI.menu("Plugins")
      menu.add_item(EXTENSION.name) { group_interior_edges }
    end

    # Merges faces while retaining a copy of the purged edges in a group.
    # Useful in my laser cutting workflow where I want to manage these edges separately for engraving
    def self.group_interior_edges
      model = Sketchup.active_model
      entities = model.active_entities
      selection = model.selection

      model.start_operation("Group Interior Edges")

      subject = selection.empty? ? entities.to_a : selection.to_a
      interior_edges =
        subject.grep(Sketchup::Edge).select { |e| our_edge?(e)  }

      # old_entities = entities.to_a

      # Creating a group from existing entities only works reliably in the active
      # entities. Hence we don't pass entities or edges as arguments to this method,
      # but limit it to the current selection.
      group = entities.add_group(interior_edges)

      #I thought SketchUp moved the existing entities into a group and created new
      ### new_entities = entities.to_a - old_entities
      ### entities.erase_entities(new_entities - [group])

      # Turns out SketchU places the copied entities in the group and retains the
      # original entities where they were.
      entities.erase_entities(interior_edges)

      # TODO: Line up axes with parent (drawing axes)?

      model.commit_operation
    end

    def self.our_edge?(edge)
      return true if edge.faces.size == 0 # Toss in free standing edges too
      return false unless coplanar_edge?(edge)

      edge.faces[0].material == edge.faces[1].material &&
        edge.faces[0].back_material == edge.faces[1].back_material
    end

    # TODO: Copy to community lib

    # Test if the two faces around an edge or planar, i.e. if the edge can be erased
    # and SketchUp merging the faces into one.
    #
    # @param edge [SketchUp::Edge]
    #
    # @return [Boolean]
    def self.coplanar_edge?(edge)
      return false unless edge.faces.size == 2

      # This check fails on faces that are very close to being co-planar, but not
      # within SketchUp's tolerance for when a face can be merged.
      ### edge.faces[0].normal.parallel?(edge.faces[1].normal)

      # SketchUp is itself inconsistent with these almost-coplanar faces between
      # merging vs erasing faces when an edge is erased, and the Smooth Soften
      # Edges function.

      # I first devised this check for my original Upright Extruder and think I even
      # managed to impress ThomThom.
      (edge.faces[0].vertices - edge.faces[1].vertices).all? do |vertex|
        vertex.position.on_plane?(edge.faces[1].plane)
      end
    end
  end
end
