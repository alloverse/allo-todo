-- a Client is used to connect this app to a Place. arg[2] is the URL of the place to
-- connect to, which Assist sets up for you.
local client = Client(
    arg[2], 
    "allo-todo"
)

-- App manages the Client connection for you, and manages the lifetime of the
-- your app.
local app = App(client)

assets = {
    quit = ui.Asset.File("images/quit.png"),
    checkmark = ui.Asset.File("images/checkmark.png"),
}
app.assetManager:add(assets)


class.TodosView(ui.View)
function TodosView:_init(bounds)
    self:super(bounds)

    self.backing = self:addSubview(ui.ModelView.BackingPlate())

    self.grabbable = true

    self.quitButton = self:addSubview(ui.Button(ui.Bounds{size=ui.Size(0.12,0.12,0.05)}))
    self.quitButton:setDefaultTexture(assets.quit)
    self.quitButton.onActivated = function()
        app:quit()
    end

    self.addButton = self:addSubview(ui.Button.Mesh(ui.Bounds{size=ui.Size(bounds.size.width*0.8,0.15,0.05)}:move(0,0,0.40)))
    self.addButton.label:setText("Add todo")
    self.addButton.onActivated = function(hand)
        self:showNewTodoPopup(hand)
    end
    
    self.todoViews = {}

    self:layout()
end

function TodosView:showNewTodoPopup(hand)
    local popup = ui.Surface(ui.Bounds{size=ui.Size(1,0.5,0.05)})

    local input = popup:addSubview(ui.TextField{
        bounds= ui.Bounds{size=ui.Size(0.8,0.1,0.05)}:move(0, 0.15, 0.025)
    })
    local done = function()
        self:addTodo(input.label.text)
        popup:removeFromSuperview()
    end
    input.onReturn = function()
        done()
        return false
    end
    input:askToFocus(hand)

    local addButton = popup:addSubview(ui.Button.Mesh(ui.Bounds{size=ui.Size(popup.bounds.size.width*0.8,0.1,0.05)}))
    addButton.bounds:move(0, 0, 0.025)
    addButton.label:setText("Add")
    addButton.onActivated = done

    local cancelButton = popup:addSubview(ui.Button.Mesh(ui.Bounds{size=ui.Size(popup.bounds.size.width*0.8,0.1,0.05)}))
    cancelButton:setSecondary(true)
    cancelButton:setColor({0.4, 0.4, 0.3, 1.0})
    cancelButton.bounds:move(0, -0.15, 0.025)
    cancelButton.label:setText("Cancel")
    cancelButton.onActivated = function()
        popup:removeFromSuperview()
    end

    app:openPopupNearHand(popup, hand)
end

function TodosView:addTodo(text)
    local todoView = ui.View(ui.Bounds{size=ui.Size(self.bounds.size.width*0.8,0.1,0.05)})
    
    local checkButton = todoView:addSubview(ui.Button(ui.Bounds{size=ui.Size(0.1, 0.1, 0.05)}))
    checkButton.bounds:move(-self.bounds.size.width/2 + checkButton.bounds.size.width, 0, 0)
    checkButton:setDefaultTexture(assets.checkmark)
    checkButton.onActivated = function()
        self:removeTodo(todoView)
    end

    local label = todoView:addSubview(ui.Label{
        bounds= todoView.bounds:copy():inset(0.1, 0.05, 0):move(0.05, 0,0),
        color= {0,0,0, 1},
        halign= "left",
        text= text
    })

    table.insert(self.todoViews, todoView)
    self:layout()
    self:addSubview(todoView)
end

function TodosView:removeTodo(todoView)
    local index = tablex.find(self.todoViews, todoView)
    table.remove(self.todoViews, index)
    todoView:removeFromSuperview()
    self:layout()
end

function TodosView:layout()
    local height = #self.todoViews * 0.13 + 0.25

    local pen = ui.Bounds{
        size=self.addButton.bounds.size:copy(),
        pose=ui.Pose(0, -height/2, self.addButton.bounds.size.depth/2)
    }
    pen:move(0, 0.07, 0)
    self.addButton:setBounds(pen:copy())
    pen:move(0, 0.15, 0)
    for i, v in ipairs(self.todoViews) do
        v:setBounds(pen:copy())
        pen:move(0, 0.13, 0)
    end

    self.quitButton.bounds:moveToOrigin():move( 0.52, height/2, 0.025)
    self.quitButton:setBounds()

    self.bounds.size.height = height
    self.backing.bounds.size = self.bounds.size:copy()
    self.backing:layout()
    self:setBounds()
end

app.mainView = TodosView(ui.Bounds(0, 1.2, -2,   1, 0.5, 0.01))
app:connect()
app:run()
