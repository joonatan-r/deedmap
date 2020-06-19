import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "GonnhirPlugins.DeedMapPlugin";

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
bg_width = bg:GetWidth();
bg_height = bg:GetHeight(); -- these need to be changed manually if stretching
bg.MouseMove = function( sender, args )
    if data[current_area].coord_x_min == nil then
        coordsLabel:SetVisible( false );
        return;
    end
    local coord_x_min = data[current_area].coord_x_min;
    local coord_y_min = data[current_area].coord_y_min;
    local coord_x_max = data[current_area].coord_x_max;
    local coord_y_max = data[current_area].coord_y_max;
    local x,y = bg:GetMousePosition();
    coordsLabel:SetText( position_to_coords( x, y, bg_width - 1, bg_height - 1, coord_x_min, coord_y_min, coord_x_max, coord_y_max ) );
    coordsLabel:SetPosition( bg_width + 25, bg_height - 25 + 35 );
    coordsLabel:SetVisible( true );
end
infoLabel = Turbine.UI.Label();
infoLabel:SetParent( window );
infoLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
infoLabel:SetWidth( 200 );
infoLabel:SetHeight( 800 );
coordsLabel = Turbine.UI.Label();
coordsLabel:SetParent( window );
coordsLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
coordsLabel:SetWidth( 500 );
disp_width = Turbine.UI.Display.GetWidth();
disp_height = Turbine.UI.Display.GetHeight();
qs = Turbine.UI.Lotro.Quickslot(); -- the same quickslot is used, its position and skill is changed based on hovered button
qs:SetParent( window );
qs:SetZOrder( 10 );
qs:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined, "" ) );
qs:SetSize( 0, 0 );
cmd = Turbine.ShellCommand();
cmd.Execute = function( sender, cmd, args )
    window:SetVisible( not window:IsVisible() );
    if window:IsVisible() then window:Activate() end
end
Turbine.Shell.AddCommand( "deedmap", cmd );
loc_buttons = {};
zoom_buttons = {};
travel_buttons = {};

filterMenu = Turbine.UI.ContextMenu();
filterMenuItems = filterMenu:GetItems();

filterButton = Turbine.UI.Lotro.Button();
filterButton:SetSize( 50, 20 );
filterButton:SetText( "Filter" );
filterButton:SetParent( window );
filterButton.Click = function( sender, args )
    filterMenuX, filterMenuY = Turbine.UI.Display.GetMousePosition();
    filterMenu:ShowMenu();
end

areaMenu = Turbine.UI.ContextMenu();
areaMenuItems = areaMenu:GetItems();

areaButton = Turbine.UI.Lotro.Button();
areaButton:SetSize( 50, 20 );
areaButton:SetText( "Area" );
areaButton:SetParent( window );
areaButton.Click = function( sender, args ) areaMenu:ShowMenu() end

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
    Turbine.PluginData.Save( Turbine.DataScope.Character, "DeedMapPluginSkills", load_data );
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
checkBox.CheckedChanged = function( sender, args ) changeArea( current_area ) end

function set_filtering( item, new_val )
    item:SetChecked( new_val );

    for i,button in pairs( loc_buttons[current_area] ) do
        if button.info.type == item:GetText() or button.info.sub_type == item:GetText() then
            button:SetVisible( new_val );
        end
    end
    if filterMenuX ~= nil and filterMenuY ~= nil then
        filterMenu:ShowMenuAt( filterMenuX, filterMenuY ); -- menu auto closes, workaround for keeping it visible
    end
end

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
    for i,button in pairs( loc_buttons[current_area] ) do
        button:SetVisible( false );
    end
    for i,button in pairs( zoom_buttons[current_area] ) do
        button:SetVisible( false );
    end
    for i,button in pairs( travel_buttons[current_area] ) do
        button:SetVisible( false );
    end
    current_area = area;

    for i,button in pairs( loc_buttons[current_area] ) do
        button:SetVisible( true );
    end
    for i,button in pairs( zoom_buttons[current_area] ) do
        button:SetVisible( true );
    end
    for i,button in pairs( travel_buttons[current_area] ) do
        button:SetVisible( true );
    end

    filterMenuItems:Clear();
    filterMenuItems:Add( Turbine.UI.MenuItem( "Select All" ) );
    filterMenuItems:Add( Turbine.UI.MenuItem( "Clear All" ) );
    filterMenuItems:Get( 1 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            set_filtering( item, true )
        end
    end
    filterMenuItems:Get( 2 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            set_filtering( item, false )
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
            set_filtering( item, new_val )
        end
    end
end

-- TODO maybe later don't load all at once

all_areas = {};

for key,val in pairs( data ) do
    if key ~= "areas" and key ~= "types" then
        all_areas[#all_areas + 1] = key;
    end
end
for i,area in pairs( all_areas ) do
    loc_buttons[area] = {};

    for j,info in pairs( data[area] ) do
        if type(j) == "number" then -- if index is a number, it contains info for a button
            loc_buttons[area][j] = LocButton( area, j, data, bg, window, infoLabel );
            loc_buttons[area][j]:SetVisible( false );
        end
    end
end
for i,area in pairs( all_areas ) do
    zoom_buttons[area] = {};

    if data[area].zoom ~= nil then
        for j,info in pairs( data[area].zoom ) do
            zoom_buttons[area][j] = ZoomButton( info.area, info.point, bg, changeArea );
            zoom_buttons[area][j]:SetVisible( false );
        end
    end
end
for i,area in pairs( all_areas ) do
    travel_buttons[area] = {};
    
    if data[area].travel ~= nil then
        for j,info in pairs( data[area].travel ) do
            travel_buttons[area][j] = TravelButton( area, j, data, bg, window, qs );
            travel_buttons[area][j]:SetVisible( false );
        end
    end
end

load_data = Turbine.PluginData.Load( Turbine.DataScope.Character, "DeedMapPluginSkills" );

if load_data ~= nil then
    function load_skills()
        for area,info in pairs( load_data ) do
            for j,skill in pairs( info ) do
                travel_buttons[area][j].skill = skill;
            end
        end
    end
    pcall( load_skills )
else 
    load_data = {}
end

changeArea( current_area );
