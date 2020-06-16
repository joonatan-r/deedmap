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
