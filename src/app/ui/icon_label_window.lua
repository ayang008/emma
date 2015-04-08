local icon_label_window = class("icon_label_window", function()
    return display.newNode()
end)

function icon_label_window:ctor()
	self.line_dis_ = DEF.ICON_LABEL_WINDOW_LINE_DIS
    self.frame_dis_ = DEF.ICON_LABEL_WINDOW_FRAME_DIS
    self.back_ground_ = display.newScale9Sprite(pic.icon_lable_window_bg, 0, 0)
                                :addTo(self)
    self.labels_ = {}
    self.back_ground_:setVisible(false)
end

function icon_label_window:set_labels(labels)
    assert(labels)

    for _, v in ipairs(self.labels_) do
        v:removeSelf()
    end
    self.labels_ = {}
    
    self.back_ground_:setVisible(false)

    if (next(labels)) then

        --this assumes the height of each label is the same
        local label_height = labels[1]:get_size().height
    
        local bg_height = 2 * self.frame_dis_
                            + (#labels - 1) * self.line_dis_ 
                            + #labels * labels[1]:get_size().height

        local height = bg_height / 2 - self.frame_dis_
        local label_width = 0
        for _, label in ipairs(labels) do
            label:setPositionY(height - label_height/2)
        
            label_width = math.max(label_width, label:get_size().width)
            height = height - self.line_dis_ - label_height
        end
        for _, label in ipairs(labels) do
            label:setPositionX((label:get_size().width - label_width)/2)
            label:addTo(self)
            table.insert(self.labels_, label)
        end
    
        local  bg_width = label_width + 2 * self.frame_dis_ 

        self.back_ground_:setContentSize(bg_width, bg_height)
        self.back_ground_:setVisible(true)
    end
end

return icon_label_window