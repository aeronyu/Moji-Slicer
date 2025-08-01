//
//  UndoManager.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/27/25.
//

import SwiftUI

enum CanvasAction {
    case addGrid(GridModel)
    case removeGrid(GridModel, at: Int)
    case modifyGrid(old: GridModel, new: GridModel, at: Int)
    case addImage(CanvasImage)
    case removeImage(CanvasImage, at: Int)
    case modifyImage(old: CanvasImage, new: CanvasImage, at: Int)
}

class CanvasUndoManager: ObservableObject {
    private var undoStack: [CanvasAction] = []
    private var redoStack: [CanvasAction] = []
    private let maxUndoActions = 50
    
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    
    func recordAction(_ action: CanvasAction) {
        undoStack.append(action)
        redoStack.removeAll() // Clear redo stack when new action is performed
        
        // Limit undo stack size
        if undoStack.count > maxUndoActions {
            undoStack.removeFirst()
        }
        
        updateCanUndoRedo()
    }
    
    func undo(grids: inout [GridModel], images: inout [CanvasImage]) -> Bool {
        guard let action = undoStack.popLast() else { return false }
        
        let reverseAction = performUndo(action: action, grids: &grids, images: &images)
        redoStack.append(reverseAction)
        
        updateCanUndoRedo()
        return true
    }
    
    func redo(grids: inout [GridModel], images: inout [CanvasImage]) -> Bool {
        guard let action = redoStack.popLast() else { return false }
        
        let reverseAction = performUndo(action: action, grids: &grids, images: &images)
        undoStack.append(reverseAction)
        
        updateCanUndoRedo()
        return true
    }
    
    private func performUndo(action: CanvasAction, grids: inout [GridModel], images: inout [CanvasImage]) -> CanvasAction {
        switch action {
        case .addGrid(let grid):
            if let index = grids.firstIndex(where: { $0.id == grid.id }) {
                grids.remove(at: index)
                return .removeGrid(grid, at: index)
            }
        case .removeGrid(let grid, let index):
            grids.insert(grid, at: min(index, grids.count))
            return .addGrid(grid)
        case .modifyGrid(let oldGrid, let newGrid, let index):
            if index < grids.count {
                grids[index] = oldGrid
                return .modifyGrid(old: newGrid, new: oldGrid, at: index)
            }
        case .addImage(let image):
            if let index = images.firstIndex(where: { $0.id == image.id }) {
                images.remove(at: index)
                return .removeImage(image, at: index)
            }
        case .removeImage(let image, let index):
            images.insert(image, at: min(index, images.count))
            return .addImage(image)
        case .modifyImage(let oldImage, let newImage, let index):
            if index < images.count {
                images[index] = oldImage
                return .modifyImage(old: newImage, new: oldImage, at: index)
            }
        }
        return action // Fallback
    }
    
    private func updateCanUndoRedo() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
    
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateCanUndoRedo()
    }
}
