import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "TestPlugin.TestStuff";

current_area = "Middle-earth";
width = data[current_area].width;
height = data[current_area].height;
window = Turbine.UI.Lotro.Window();
window:SetPosition( 0, 0 );
window:SetText( "Map" );
window:SetVisible( true );
window:Activate();
bg = Turbine.UI.Control();
bg:SetParent( window );
bg:SetPosition( 20, 35 );
infoLabel = Turbine.UI.Label();
infoLabel:SetParent( window );
infoLabel:SetWidth( 200 );
infoLabel:SetHeight( 800 );
coordsLabel = Turbine.UI.Label();
coordsLabel:SetParent( window );
disp_width = Turbine.UI.Display.GetWidth();
disp_height = Turbine.UI.Display.GetHeight();

------------------

bg.MouseClick = function( sender, args )
    if args.Button == Turbine.UI.MouseButton.Left then
        local x,y = bg:GetMousePosition();
        x = x - 30; -- adjust for image, - 5 for loc, - 30 for zoom, - 15 for travel
        y = y - 30;
        Turbine.Shell.WriteLine( "{" .. x .. ", " .. y .. "};" );
    elseif args.Button == Turbine.UI.MouseButton.Right and data[current_area].main_area ~= nil then
        changeArea( data[current_area].main_area );
    end
end

---------------

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0);
    return math.floor(num * mult + 0.5) / mult;
end

-- mins in top left, maxes in bottom right, positions are numbers, coords strings in format "74.9W", "113.1S" etc

function positionToCoords( pos_x, pos_y, pos_x_max, pos_y_max, coord_x_min, coord_y_min, coord_x_max, coord_y_max )
    local side_x_min = coord_x_min:sub( -1 );
    local side_y_min = coord_y_min:sub( -1 );
    local side_x_max = coord_x_max:sub( -1 );
    local side_y_max = coord_y_max:sub( -1 );
    local coord_x_min = tonumber( coord_x_min:sub( 1, -2 ) );
    local coord_y_min = tonumber( coord_y_min:sub( 1, -2 ) );
    local coord_x_max = tonumber( coord_x_max:sub( 1, -2 ) );
    local coord_y_max = tonumber( coord_y_max:sub( 1, -2 ) );
    local relative_dist_x = pos_x / pos_x_max; -- assume min positions of 0, 0
    local relative_dist_y = pos_y / pos_y_max;
    local coord_x, coord_y;
    local side_x = nil;
    local side_y = nil;

    if side_x_min == "W" and side_x_max == "W" then
        local coord_x_span = coord_x_min - coord_x_max;
        coord_x = coord_x_min - relative_dist_x * coord_x_span;
        side_x = "W";
    elseif side_x_min == "E" and side_x_max == "E" then
        local coord_x_span = coord_x_max - coord_x_min;
        coord_x = coord_x_min + relative_dist_x * coord_x_span;
        side_x = "E";
    elseif side_x_min == "W" and side_x_max == "E" then
        local coord_x_span = coord_x_max + coord_x_min;
        coord_x = coord_x_min - relative_dist_x * coord_x_span;

        if coord_x < 0 then
            coord_x = -coord_x;
            side_x = "E";
        else
            side_x = "W";
        end
    end

    if side_y_min == "N" and side_y_max == "N" then
        local coord_y_span = coord_y_min - coord_y_max;
        coord_y = coord_y_min - relative_dist_y * coord_y_span;
        side_y = "N";
    elseif side_y_min == "S" and side_y_max == "S" then
        local coord_y_span = coord_y_max - coord_y_min;
        coord_y = coord_y_min + relative_dist_y * coord_y_span;
        side_y = "S";
    elseif side_y_min == "N" and side_y_max == "S" then
        local coord_y_span = coord_y_max + coord_y_min;
        coord_y = coord_y_min - relative_dist_y * coord_y_span;

        if coord_y < 0 then
            coord_y = -coord_y;
            side_y = "S";
        else
            side_y = "N";
        end
    end

    if side_x == nil or side_y == nil then return "" end
    coord_x = tostring( round( coord_x, 1 ) ) .. side_x;
    coord_y = tostring( round( coord_y, 1 ) ) .. side_y;
    return coord_y .. " " .. coord_x;
end

bg_width = bg:GetWidth();
bg_height = bg:GetHeight(); -- these need to be changed manually if stretching

bg.MouseMove = function(sender, args)
    if data[current_area].coord_x_min == nil then
        coordsLabel:SetVisible( false );
        return;
    end
    
    local coord_x_min = data[current_area].coord_x_min;
    local coord_y_min = data[current_area].coord_y_min;
    local coord_x_max = data[current_area].coord_x_max;
    local coord_y_max = data[current_area].coord_y_max;
    local x,y = bg:GetMousePosition();
    coordsLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
    coordsLabel:SetText( positionToCoords( x, y, bg_width - 1, bg_height - 1, coord_x_min, coord_y_min, coord_x_max, coord_y_max ) );
    coordsLabel:SetWidth( 500 );
    coordsLabel:SetPosition( bg_width + 25, bg_height - 25 + 35 );
    coordsLabel:SetVisible( true );
end

---------------

cmd = Turbine.ShellCommand();
cmd.Execute = function( sender, cmd, args )
    window:SetVisible( not window:IsVisible() );
    if window:IsVisible() then window:Activate() end
end
Turbine.Shell.AddCommand( "deedmap", cmd );

---------------

LocButton = class( Turbine.UI.Button );

function LocButton:Constructor( area, idx )
    Turbine.UI.Button.Constructor( self );
    self.selected = false;
    self.area = area;
    self.idx = idx;
    self.label = Turbine.UI.Label();
    self.label:SetBackColor( Turbine.UI.Color( 0, 0, 0 ) );
    self.label:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
    self:SetSize( 16, 16 );
    self:SetBackground( 0x410f34f1 );
    self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    self:SetParent( bg );
    self.label:SetParent( window ); -- label parent is window so that it won't be scaled if bg map needs to be resized
    self.label:SetVisible( false );
    self.info = data[area][idx];
    self:SetPosition( unpack(self.info.point) );
    self.MouseEnter = function(sender, args)
        local x,y = window:GetMousePosition();
        self.label:SetText( self.info.text );
        self.label:SetPosition( x + 25, y - 25 );
        self.label:SetWidth( self.label:GetTextLength() * 8 );
        self.label:SetHeight( 25 );
        self.label:SetVisible( true );
        self.label:SetZOrder( 10 ); -- show on top
        self.label:SetStretchMode( 1 ); -- renders outside bounds
    end
    self.MouseLeave = function(sender, args)
        self.label:SetVisible( false );
    end
    self.Click = function( sender, args )
        changeSelection( self.area, self.idx, self.selected );
        infoLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
        infoLabel:SetText( self.info.desc );
        infoLabel:SetVisible( self.selected );
    end
end

changeSelection = function( area, idx, remove_selection )
    for i,button in pairs( loc_buttons[area] ) do
        if remove_selection or i ~= idx then
            button:SetBackground( 0x410f34f1 );
            button.selected = false;
        else
            button:SetBackground( 0x410d7856 );
            button.selected = true;
        end
    end
end

ZoomButton = class( Turbine.UI.Button );

function ZoomButton:Constructor( area, point )
    Turbine.UI.Button.Constructor( self );
    self:SetBackground( 0x410081a2 );
    self:SetSize( 63, 63 );
    self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    self:SetParent( bg );
    self:SetPosition( unpack( point ) );
    self.area = area;
    self.MouseEnter = function(sender, args)
        self:SetBlendMode( Turbine.UI.BlendMode.Multiply );
    end
    self.MouseLeave = function(sender, args)
        self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    end
    self.Click = function( sender, args )
        changeArea( self.area );
    end
end

qs = Turbine.UI.Lotro.Quickslot(); -- the same quickslot is used, its position and skill is changed based on hovered button
qs:SetParent( window );
qs:SetZOrder( 10 );
qs:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined, "" ) );
qs:SetSize( 0, 0 );

TravelButton = class( Turbine.UI.Lotro.Button );

function TravelButton:Constructor( area, idx )
    Turbine.UI.Button.Constructor( self );
    self.x, self.y = unpack( data[area].travel[idx].point );
    self.skill = data[area].travel[idx].skill;
    self.idx = idx;
    self:SetParent( bg );
    self:SetPosition( self.x, self.y );
    self:SetSize( 30, 30 );
    self:SetBackground( 0x41005e52 );
    self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    self.MouseEnter = function( sender, args )
        self:SetBackground( 0x41005e55 );
        qs:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Skill, self.skill ) );
        qs.MouseLeave = function( sender, args )
            local x,y = bg:GetMousePosition();
        
            if not ( x >= self.x and x <= self.x + 29 ) or not ( y >= self.y and y <= self.y + 29 ) then
                self:SetBackground( 0x41005e52 );
            end
        end
        self:SetWantsUpdates( true );
    end
    self.MouseLeave = function( sender, args )
        self:SetWantsUpdates( false );
    end
    self.Update = function( sender, args )
        local x, y = window:GetMousePosition();
        qs:SetPosition( x - 1, y - 1 );
        qs:SetSize( 3, 3 );
    end
    self.EnterEdit = function()
        self.qs = Turbine.UI.Lotro.Quickslot();
        self.qs:SetParent( bg );
        self.qs:SetPosition( self.x, self.y );
        self.qs:SetZOrder( 10 );
        self.qs:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Skill, self.skill ) );
        self.qs.ShortcutChanged = function( sender, args )
            self.skill = self.qs:GetShortcut():GetData();
        end
    end
    self.ExitEdit = function()
        self.qs:SetVisible( false );
    end
end

------------------

-- TODO maybe later don't load all at once

all_areas = {};

for key,val in pairs( data ) do
    if key ~= "areas" and key ~= "types" then
        all_areas[#all_areas + 1] = key;
    end
end

loc_buttons = {};

for i,area in pairs( all_areas ) do
    loc_buttons[area] = {};

    for j,info in pairs( data[area] ) do
        if type(j) == "number" then -- if index is a number, it contains info for a button
            loc_buttons[area][j] = LocButton( area, j );
            loc_buttons[area][j]:SetVisible( false );
        end
    end
end

for i,button in pairs( loc_buttons[current_area] ) do
    button:SetVisible( true );
end

zoom_buttons = {};

for i,area in pairs( all_areas ) do
    zoom_buttons[area] = {};

    if data[area].zoom ~= nil then
        for j,info in pairs( data[area].zoom ) do
            zoom_buttons[area][j] = ZoomButton( info.area, info.point );
            zoom_buttons[area][j]:SetVisible( false );
        end
    end
end

for i,button in pairs( zoom_buttons[current_area] ) do
    button:SetVisible( true );
end

travel_buttons = {};

for i,area in pairs( all_areas ) do
    travel_buttons[area] = {};

    if data[area].travel ~= nil then
        for j,info in pairs( data[area].travel ) do
            travel_buttons[area][j] = TravelButton( area, j );
            travel_buttons[area][j]:SetVisible( false );
        end
    end
end

for i,button in pairs( travel_buttons[current_area] ) do
    button:SetVisible( true );
end

load_data = Turbine.PluginData.Load( Turbine.DataScope.Character, "TestPlugin_saved_skills" );

function load_skills()
    for area,info in pairs( load_data ) do
        for j,skill in pairs( info ) do
            travel_buttons[area][j].skill = skill;
        end
    end
end

if load_data ~= nil then pcall( load_skills )
else load_data = {} end

---------------

filterButton = Turbine.UI.Lotro.Button();
filterButton:SetSize( 50, 20 );
filterButton:SetText( "Filter" );
filterButton:SetParent( window );
filterButton.Click = function( sender, args )
    filterMenu:ShowMenu();
end
filterMenu = Turbine.UI.ContextMenu();
filterMenuItems = filterMenu:GetItems();

areaButton = Turbine.UI.Lotro.Button();
areaButton:SetSize( 50, 20 );
areaButton:SetText( "Area" );
areaButton:SetParent( window );
areaButton.Click = function( sender, args )
    areaMenu:ShowMenu();
end
areaMenu = Turbine.UI.ContextMenu();
areaMenuItems = areaMenu:GetItems();

for i,area in pairs( data.areas ) do
    areaMenuItems:Add( Turbine.UI.MenuItem( area ) );
end

for i = 1, areaMenuItems:GetCount() do
    local item = areaMenuItems:Get( i );
    item.Click = function( sender, args )
        local area = item:GetText();
        changeArea( area );
    end
end

function enter_edit( sender, args )
    for i,button in pairs( travel_buttons[current_area] ) do
        button.EnterEdit();
    end
    editButton.Click = function( sender, args ) exit_edit( sender, args ) end
end

function exit_edit( sender, args )
    for i,button in pairs( travel_buttons[current_area] ) do
        button.ExitEdit();
        
        if button.skill ~= data[current_area].travel[button.idx].skill then -- no point saving custom skill if it's the default one
            if load_data[current_area] == nil then load_data[current_area] = {} end
            load_data[current_area][button.idx] = button.skill;
        end
    end
    Turbine.PluginData.Save( Turbine.DataScope.Character, "TestPlugin_saved_skills", load_data );
    editButton.Click = function( sender, args ) enter_edit( sender, args ) end
end

editButton = Turbine.UI.Lotro.Button();
editButton:SetSize( 50, 20 );
editButton:SetText( "Skills" );
editButton:SetParent( window );
editButton.Click = function( sender, args ) enter_edit( sender, args ) end

checkBox = Turbine.UI.Lotro.CheckBox();
checkBox:SetParent( window );
checkBox:SetText( " Stretch map to max size" );
checkBox:SetWidth( 220 );
checkBox.CheckedChanged = function( sender, args )
    changeArea( current_area );
end

-------------

function changeArea( area )
    width = data[area].width;
    height = data[area].height;
    bg_width = width;
    bg_height = height;
    window:SetSize( width + 40 + 220, height + 57 );
    bg:SetBackground( data[area].map );
    bg:SetStretchMode( 0 );
    bg:SetSize( bg_width, bg_height );
    bg:SetPosition( 20, 35 );
    
    ----------

    local adjusted = false;
    local window_width = window:GetWidth();
    local window_height = window:GetHeight();

    if window_width > disp_width or window_height > disp_height or checkBox:IsChecked() then
        local ratio = window_width / window_height;
        local disp_ratio = disp_width / disp_height;

        if disp_ratio < ratio then 
            local new_height = (disp_width / window_width) * window_height;
            window:SetSize( disp_width, new_height );
        else
            local new_width = (disp_height / window_height) * window_width;
            window:SetSize( new_width, disp_height );
        end

        window_width = window:GetWidth();
        window_height = window:GetHeight();
        adjusted = true;
    end

    if adjusted then
        bg_width = window_width - 40 - 220;
        bg_height = window_height - 57;
        window:SetPosition( 0, 0 );
        bg:SetStretchMode( 1 );
        bg:SetSize( bg_width, bg_height );
        filterButton:SetPosition( window_width - 220, 35 + 20 );
        areaButton:SetPosition( window_width - 220 + 70, 35 + 20 );
        editButton:SetPosition( window_width - 220 + 70 + 70, 35 + 20 );
        checkBox:SetPosition( window_width - 220, 35 + 50 );
        infoLabel:SetPosition( window_width - 220, 35 + 100 );
    else
        filterButton:SetPosition( width + 20 + 20, 35 + 20 );
        areaButton:SetPosition( width + 20 + 20 + 70, 35 + 20 );
        editButton:SetPosition( width + 20 + 20 + 70 + 70, 35 + 20 );
        checkBox:SetPosition( width + 20 + 20, 35 + 50 );
        infoLabel:SetPosition( width + 20 + 20, 35 + 100 );
    end

    ---------

    local prev_area = current_area;
    current_area = area;

    for i,button in pairs( loc_buttons[prev_area] ) do
        button:SetVisible( false );
    end

    for i,button in pairs( zoom_buttons[prev_area] ) do
        button:SetVisible( false );
    end

    for i,button in pairs( travel_buttons[prev_area] ) do
        button:SetVisible( false );
    end

    for i,button in pairs( loc_buttons[current_area] ) do
        button:SetVisible( true );
    end

    for i,button in pairs( zoom_buttons[current_area] ) do
        button:SetVisible( true );
    end

    for i,button in pairs( travel_buttons[current_area] ) do
        button:SetVisible( true );
    end

    ---------

    filterMenuItems:Clear();
    filterMenuItems:Add( Turbine.UI.MenuItem( "Select All" ) );
    filterMenuItems:Add( Turbine.UI.MenuItem( "Clear All" ) );
    filterMenuItems:Get( 1 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            item:SetChecked( true );
    
            for i,button in pairs( loc_buttons[current_area] ) do
                if button.info.type == item:GetText() or button.info.sub_type == item:GetText() then
                    button:SetVisible( true );
                end
            end
        end
    end
    filterMenuItems:Get( 2 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            item:SetChecked( false );
    
            for i,button in pairs( loc_buttons[current_area] ) do
                if button.info.type == item:GetText() or button.info.sub_type == item:GetText() then
                    button:SetVisible( false );
                end
            end
        end
    end

    for i,type in pairs( data.types ) do
        filterMenuItems:Add( Turbine.UI.MenuItem( type ) );
    end

    for i,type in pairs( data[current_area].sub_types ) do
        filterMenuItems:Add( Turbine.UI.MenuItem( type ) );
    end

    for i = 3, filterMenuItems:GetCount() do
        local item = filterMenuItems:Get( i );
        item:SetChecked( true );
        item.Click = function( sender, args )
            new_val = not item:IsChecked();
            item:SetChecked( new_val );
    
            for i,button in pairs( loc_buttons[current_area] ) do
                if button.info.type == item:GetText() or button.info.sub_type == item:GetText() then
                    button:SetVisible( new_val );
                end
            end
        end
    end
end

changeArea( current_area );
