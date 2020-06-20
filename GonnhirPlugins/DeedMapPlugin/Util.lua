import "Turbine.UI";
import "Turbine.UI.Lotro";

Selection = {};

function Selection:SetLoc( locButton )
    if self.current ~= nil then
        self.current:SetBackground( 0x410f34f1 );
        self.current.selected = false;
    end
    if locButton ~= nil then
        locButton:SetBackground( 0x410d7856 );
        locButton.selected = true;
    end
    self.current = locButton;
end

LocButton = class( Turbine.UI.Button );

function LocButton:Constructor( area, idx, data, bg, window, infoLabel )
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
        self.label:SetWidth( get_text_width( self.info.text ) );
        self.label:SetHeight( 25 );
        self.label:SetVisible( true );
        self.label:SetZOrder( 10 ); -- show on top
        self.label:SetStretchMode( 1 ); -- renders outside bounds
    end
    self.MouseLeave = function(sender, args) self.label:SetVisible( false ) end
    self.Click = function( sender, args )
        if not self.selected then
            Selection:SetLoc( self );
        else
            Selection:SetLoc( nil );
        end
        infoLabel:SetText( self.info.desc );
        infoLabel:SetVisible( self.selected );
    end
end

ZoomButton = class( Turbine.UI.Button );

function ZoomButton:Constructor( area, point, bg, changeArea )
    Turbine.UI.Button.Constructor( self );
    self:SetBackground( 0x410081a2 );
    self:SetSize( 63, 63 );
    self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    self:SetParent( bg );
    self:SetPosition( unpack( point ) );
    self.area = area;
    self.MouseEnter = function( sender, args ) self:SetBlendMode( Turbine.UI.BlendMode.Multiply ) end
    self.MouseLeave = function( sender, args ) self:SetBlendMode( Turbine.UI.BlendMode.Overlay ) end
    self.Click = function( sender, args ) changeArea( self.area ) end
end

TravelButton = class( Turbine.UI.Lotro.Button );

function TravelButton:Constructor( area, idx, data, bg, window, qs )
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
    self.MouseLeave = function( sender, args ) self:SetWantsUpdates( false ) end
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
    self.ExitEdit = function() self.qs:SetVisible( false ) end
end

function round( num, numDecimalPlaces )
    local mult = 10^(numDecimalPlaces or 0);
    return math.floor(num * mult + 0.5) / mult;
end

-- mins in top left, maxes in bottom right, positions are numbers, coords strings in format "74.9W", "113.1S" etc

function position_to_coords( pos_x, pos_y, pos_x_max, pos_y_max, coord_x_min, coord_y_min, coord_x_max, coord_y_max )
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

function get_text_width( text )
    local width = 0;

    for i = 1, #text do
        local c = text:sub(i,i)

        if text_width.BookAntiqua20[c] == nil then
            width = width + 15;
        else
            -- some extra space seems to be needed, 1 each iteration is quite generous though
            width = width + text_width.BookAntiqua20[c] + 1;
        end
    end
    return width;
end

-- sizes don't seem to always be exactly the same

text_width = {};
text_width.BookAntiqua20 = {};
text_width.BookAntiqua20.A = 12;
text_width.BookAntiqua20.B = 8;
text_width.BookAntiqua20.C = 10;
text_width.BookAntiqua20.D = 11;
text_width.BookAntiqua20.E = 8;
text_width.BookAntiqua20.F = 7;
text_width.BookAntiqua20.G = 11;
text_width.BookAntiqua20.H = 11;
text_width.BookAntiqua20.I = 4;
text_width.BookAntiqua20.J = 4;
text_width.BookAntiqua20.K = 10;
text_width.BookAntiqua20.L = 8;
text_width.BookAntiqua20.M = 13;
text_width.BookAntiqua20.N = 11;
text_width.BookAntiqua20.O = 11;
text_width.BookAntiqua20.P = 8;
text_width.BookAntiqua20.Q = 11;
text_width.BookAntiqua20.R = 9;
text_width.BookAntiqua20.S = 7;
text_width.BookAntiqua20.T = 9;
text_width.BookAntiqua20.U = 11;
text_width.BookAntiqua20.V = 11;
text_width.BookAntiqua20.W = 15;
text_width.BookAntiqua20.X = 10;
text_width.BookAntiqua20.Y = 10;
text_width.BookAntiqua20.Z = 9;
text_width.BookAntiqua20.a = 8;
text_width.BookAntiqua20.b = 7;
text_width.BookAntiqua20.c = 6;
text_width.BookAntiqua20.d = 8;
text_width.BookAntiqua20.e = 6;
text_width.BookAntiqua20.f = 5;
text_width.BookAntiqua20.g = 8;
text_width.BookAntiqua20.h = 9;
text_width.BookAntiqua20.i = 4;
text_width.BookAntiqua20.j = 3;
text_width.BookAntiqua20.k = 8;
text_width.BookAntiqua20.l = 4;
text_width.BookAntiqua20.m = 13;
text_width.BookAntiqua20.n = 9;
text_width.BookAntiqua20.o = 7;
text_width.BookAntiqua20.p = 8;
text_width.BookAntiqua20.q = 8;
text_width.BookAntiqua20.r = 6;
text_width.BookAntiqua20.s = 5;
text_width.BookAntiqua20.t = 5;
text_width.BookAntiqua20.u = 9;
text_width.BookAntiqua20.v = 9;
text_width.BookAntiqua20.w = 12;
text_width.BookAntiqua20.x = 8;
text_width.BookAntiqua20.y = 9;
text_width.BookAntiqua20.z = 7;
text_width.BookAntiqua20["1"] = 7;
text_width.BookAntiqua20["2"] = 7;
text_width.BookAntiqua20["3"] = 7;
text_width.BookAntiqua20["4"] = 8;
text_width.BookAntiqua20["5"] = 7;
text_width.BookAntiqua20["6"] = 7;
text_width.BookAntiqua20["7"] = 8;
text_width.BookAntiqua20["8"] = 7;
text_width.BookAntiqua20["9"] = 7;
text_width.BookAntiqua20["0"] = 7;
text_width.BookAntiqua20["."] = 3;
text_width.BookAntiqua20[","] = 3;
text_width.BookAntiqua20[" "] = 6;
text_width.BookAntiqua20["("] = 4;
text_width.BookAntiqua20[")"] = 4;
text_width.BookAntiqua20["["] = 4;
text_width.BookAntiqua20["]"] = 5; -- ???
