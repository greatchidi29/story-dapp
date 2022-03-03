import { useState } from "react";

import "./slot.css";

const Storyslot = (props) => {
  const [title, setTitle] = useState("");
  const [story, setStory] = useState("");
  const [amount, setAmount] = useState("");

  const formHandler = (event) => {
    event.preventDefault();
    props.createStory(title, story, amount);
  };

  const buyStory = (_index, _amount) => {
    props.buyStory(_index, _amount);
  };

  const sellStory = (index) => {
    props.sellStory(index);
  };

  const likeStory = (index)=>{
    props.likeStory(index);
  }
  return (
    <div className="bg-dark" style={{ padding: "36px" }}>
      <div className="row row-cols-2 row-cols-md-3 mb-3">
        {props.stories.map((story) => (
          <div className="col">
            <div className="card mb-4 rounded-3 shadow-sm">
              <div className="card-body">
                <h5 className="card-title pricing-card-title">
                  Title: {story.title}
                </h5>
                <p>owned by: {story.owner} </p>
                <p>{story.story}</p>

                <h5>Priced at: {story.amount} cUSD</h5>
                <div onClick={()=>likeStory(story.index)} className="d-flex justify-content-between">
                  <p>{story.likes} likes</p>
                  <span>
                    <i class="fa fa-heart" aria-hidden="true"></i>
                  </span>
                </div>
                <div className="row">
                  <div className="col-6">
                    {story.isPaid && story.owner === props.address && (
                      <button
                        onClick={() => sellStory(story.index, story.amount)}
                        className="btn btn-danger"
                      >
                        Sell Story
                      </button>
                    )}

                    {story.isPaid === false && story.owner !== props.address &&
                      (
                      <button
                        onClick={() => buyStory(story.index, story.amount)}
                        className="btn btn-danger"
                      >
                        Buy Story
                      </button>
                    )
                    }
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
      <div className="row">
        <div className="col-6">
          <form onSubmit={formHandler}>
            <h2>Your Journey awaits</h2>
            <div className="mb-3">
              <label className="form-label">Title</label>
              <input
                type="text"
                className="form-control"
                onChange={(e) => setTitle(e.target.value)}
              />
            </div>
            <div className="mb-3">
              <label className="form-label">Story</label>
              <textarea
                className="form-control"
                rows={5}
                onChange={(e) => setStory(e.target.value)}
              />
            </div>
            <div className="mb-3">
              <label className="form-label">Amount</label>
              <input
                type="text"
                className="form-control"
                onChange={(e) => setAmount(e.target.value)}
              />
            </div>
            <button type="submit" className="btn btn-danger">
              Add
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Storyslot;
