import React, { useState } from 'react';
import Picker from 'react-mobile-picker';
import './TablewarePicker.css';

const TablewarePicker = ({ value, onChange }) => {
  const [isOpen, setIsOpen] = useState(false);

  const options = {
    tableware: [
      '无需餐具',
      '需要餐具,商家依据餐量提供',
      '1份', '2份', '3份', '4份', '5份', '6份', '7份', '8份', '9份', '10份',
      '10份以上'
    ]
  };

  const handleChange = (newValue) => {
    onChange(newValue.tableware);
  };

  const handleConfirm = () => {
    setIsOpen(false);
  };

  return (
    <div>
      <div className="tableware-picker-trigger" onClick={() => setIsOpen(true)}>
        {value}
      </div>
      {isOpen && (
        <div className="tableware-picker-modal">
          <div className="picker-container">
            <Picker
              value={{ tableware: value }}
              onChange={handleChange}
              wheel="normal"
              height={180}
            >
              {Object.keys(options).map(name => (
                <Picker.Column key={name} name={name}>
                  {options[name].map(option => (
                    <Picker.Item key={option} value={option}>
                      {option}
                    </Picker.Item>
                  ))}
                </Picker.Column>
              ))}
            </Picker>
            <div className="picker-footer">
              <button onClick={() => setIsOpen(false)}>取消</button>
              <button onClick={handleConfirm}>确定</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TablewarePicker;
