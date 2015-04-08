local icon_label = class("icon_label", function()
    return display.newNode()
end)

function icon_label:ctor(icon, text, text_size)
    assert(icon and text)

    self.icon_ = display.newSprite(icon):addTo(self)
    self.label_ = display.newTTFLabel({
                                        UILabelType = 2,
                                        text = text,
                                        size = text_size or 20,
                                        x = 0,
                                        y = 0,
                                        align = cc.TEXT_ALIGNMENT_LEFT,
                                     })
                                     :addTo(self)

    local icon_size = self.icon_:getContentSize()
    local lable_size = self.label_:getContentSize()

    self.width_ = icon_size.width + lable_size.width
    self.height_ = math.max(lable_size.height, icon_size.height)

    self.icon_:pos((icon_size.width - self.width_) / 2, 0)
    self.label_:pos(icon_size.width - self.width_/2 + lable_size.width/2, 0)
end

function icon_label:get_size()
    return { width = self.width_, height = self.height_ }
end

return icon_label