function links = runmap(imgname)

	%imgname = 'MAP.png';
	map = imread(imgname);
	dotsColor = [237, 28, 36];
	dots = getDots(map, dotsColor);
	links = {};

	for i = 1:length(dots)
		d = dots{i};
		link = checkLink(dots, i, d, map, 50, dotsColor);
		links{end+1} = link;
	end

    showLink(map, links);
    writeLink(links, 'links.txt');

end

function writeLink(links, filename)

	fileID = fopen(filename,'w');
	fprintf(fileID, 'total dots = %d\n', length(links));
	for i = 1:length(links)
		fprintf(fileID, '%d %d %d\n', links{i}.id, links{i}.pos(1), links{i}.pos(2));
	end
	fprintf(fileID, 'print all links\n');
	for i = 1:length(links)
		neighbor = links{i}.neighbor;
		fprintf(fileID, 'id %d neighbor:\n', links{i}.id);
		for j = 1:length(neighbor)
			fprintf(fileID, '%d ', neighbor(j));
		end
		fprintf(fileID, '\n');
	end
	fclose(fileID);

end

function showLink(map, links)

	imshow(map);
	hold on;

	for i = 1:length(links)
		s = links{i}.pos;
		neighbor = links{i}.neighbor;
		for j = 1:length(neighbor)
			e = links{neighbor(j)}.pos;
			e = s*0.7 + e*0.3;
			line([s(1), e(1)], [s(2), e(2)], 'LineWidth',3, 'Color', 'g');
		end
	end

	hold off;

end

function link = checkLink(dots, index, d, map, maxlength, dotsColor)

	% each 10 degree, get 36 directions
	degree = 0:359;

	link.id = index;
	link.pos = d;
	neighbor = [];

	[h, w, ~] = size(map);

	for i = 1:length(degree)
		deg = degree(i);
		line_pos = getline(d, deg, maxlength);
		for j = 1:length(line_pos)
			pixel = line_pos{j};
    
            x = pixel(1);
            y = pixel(2);
			if y < 1 || y > h || x < 1 || x > w
				continue;
            end
			p_color = single(map(y, x, :));
			p_gray = sum(p_color)/3;
			if p_color(1) == dotsColor(1) && p_color(2) == dotsColor(2) && p_color(3) == dotsColor(3) 
				% dots
				id = getDotId(pixel, dots);
				neighbor(end+1) = id;
				break;
			elseif p_gray > 150
				% object
				break;
			end
		end
	end

	link.neighbor = unique(neighbor);
end

function id = getDotId(pixel, dots)

	id = 0;
	for i = 1:length(dots)
		pos = dots{i};
		if pixel(1) == pos(1) && pixel(2) == pos(2)
			id = i;
			break;
		end
	end

end

function line_pos = getline(d, degree, maxlength)

	rayd = [cosd(degree), sind(degree)];
	start_pixel = d;
	end_pixel = start_pixel + round(maxlength * rayd);
	x_pos = round(linspace(start_pixel(1), end_pixel(1), maxlength*3));
	y_pos = round(linspace(start_pixel(2), end_pixel(2), maxlength*3));
	line_pos = {};
	for i = 1:length(x_pos)
		pixel = [x_pos(i), y_pos(i)];
		if pixel(1) ~= start_pixel(1) || pixel(2) ~= start_pixel(2)
			line_pos{end+1} = int32(pixel);
			start_index = i;
			break;
		end
	end
	for j = start_index:length(x_pos)
		pixel = [x_pos(j), y_pos(j)];
		if pixel(1) ~= line_pos{end}(1) || pixel(2) ~= line_pos{end}(2)
			line_pos{end+1} = int32(pixel);
		end
    end

end

function dots = getDots(img, dotsColor)
	
	dots = {};

	s = size(img);
	h = s(1); w = s(2); c = s(3);
	for y = 1:h
		for x = 1:w
			color = img(y, x, :);
			if  color(1) == dotsColor(1) && color(2) == dotsColor(2) && color(3) == dotsColor(3) 
				dots{end+1} = [x, y];	
			end			
		end
	end	

end





