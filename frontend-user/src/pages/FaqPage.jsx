import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import './FaqPage.css';

const FaqItem = ({ question, answer }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="faq-item">
      <div className="faq-question" onClick={() => setIsOpen(!isOpen)}>
        <span>{question}</span>
        <span className={`faq-arrow ${isOpen ? 'open' : ''}`}>▼</span>
      </div>
      {isOpen && <div className="faq-answer">{answer}</div>}
    </div>
  );
};

const FaqPage = () => {
  const faqData = {
    "订单问题": [
      {
        q: "下单后可以修改订单吗？",
        a: "为了保证出餐效率和准确性，用户提交订单后无法直接修改。如需更改，您可以在商家接单前取消订单并重新下单。"
      },
      {
        q: "如何取消订单？",
        a: "在‘我的订单’页面，处于‘待付款’或‘待接单’状态的订单可以被取消。点击订单卡片上的‘取消订单’按钮即可。"
      },
      {
        q: "收到的餐品有误或有质量问题怎么办？",
        a: "请立即通过客服热线 400-123-4567 联系我们，我们将第一时间为您处理。"
      }
    ],
    "支付与退款": [
      {
        q: "支持哪些支付方式？",
        a: "目前我们支持支付宝和微信支付。"
      },
      {
        q: "取消订单后，钱款如何退回？",
        a: "如果您已支付，取消订单后款项将在1-3个工作日内原路退回到您的支付账户。"
      }
    ],
    "配送问题": [
      {
        q: "配送范围和费用是如何计算的？",
        a: "我们的标准配送范围是3公里内，基础配送费为5元。超出范围可能会产生额外费用。"
      },
      {
        q: "预计送达时间是多久？",
        a: "您在下单时可以看到预估的送达时间。该时间根据出餐速度和配送距离动态计算。"
      }
    ]
  };

  return (
    <div className="faq-page">
      <header className="faq-header">
        <Link to="/profile" className="back-button">&lt;</Link>
        <h1>常见问题</h1>
      </header>
      <main className="faq-content">
        {Object.entries(faqData).map(([category, items]) => (
          <div key={category} className="faq-category">
            <h2>{category}</h2>
            {items.map((item, index) => (
              <FaqItem key={index} question={item.q} answer={item.a} />
            ))}
          </div>
        ))}
      </main>
    </div>
  );
};

export default FaqPage;
