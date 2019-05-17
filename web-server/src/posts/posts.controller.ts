import * as express from 'express';
import Controller from '../interfaces/controller.interface';
import Post from './post.interface';
import postModel from './posts.model';

class PostsController implements Controller {
  public path = '/posts';
  public router = express.Router();

  constructor() {
    this.initializeRoutes();
  }

  public initializeRoutes() {
    this.router.get(this.path, this.getAllPosts);
    this.router.get(`${this.path}/:id`, this.getPostById);
    this.router.patch(`${this.path}/:id`, this.modifyPost);
    this.router.post(this.path, this.createPost);
    this.router.delete(`${this.path}/:id`, this.deletePost);
  }

  private getAllPosts = (request: express.Request, response: express.Response) => {
    postModel.find()
      .then((posts) => {
        response.send(posts);
      })
  }

  private getPostById = (request: express.Request, response: express.Response) => {
    const id = request.params.id;
    postModel.findById(id)
      .then((post) => {
        if (post) {
          response.send(post);
        } else {
          response.status(404).send({error: 'Post not found'});
        }
      });
  }

  private modifyPost = (request: express.Requsest, response: express.Response) => {
    const id = request.params.id;
    const postData: Post = request.body;
    postModel.findByIdAndUpdate(id, postData, { new: true })
      .then((post) => {
        response.send(post);
      });
  }

  private createPost = (request: express.Requset, response: express.Response) => {
    const postData: Post  = request.body;
    const createdPost = new postModel(postData);
    createdPost.save()
      .then((savedPost) => {
        response.send(savedPost);
      });
  }

  private deletePost = (request: express.Request, response: express.Response) => {
    const id = request.params.id;
    postModel.findByIdAndDelete(id)
      .then((successResponse) => {
        if (successResponse) {
          response.send(200);
        } else {
          response.send(404);
        }
      });
  }
}

export default PostsController;